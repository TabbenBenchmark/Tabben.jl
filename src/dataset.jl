using LazyArtifacts
using NPZ
using Tables
using TOML

const _metadata = TOML.parsefile(joinpath(artifact"metadata", "data.toml"))
const datasets = keys(_metadata)


struct TabularDataset{
        DataElType <: Number,
        TargetElType <: Number,
        ExtrasType <: Union{Dict{String, Any},Nothing}
    }

    input::Matrix{DataElType}
    output::Matrix{TargetElType}
    metadata::Dict{String, Any}
    extras::ExtrasType
    input_names::Vector{Symbol}
    output_names::Vector{Symbol}

    function TabularDataset(input, output, metadata, extras=nothing)
        ndims(input) != 2 && throw("input must have exactly 2 dimensions")
        ndims(output) ∉ 2 && throw("output must have 2 dimensions")
        size(input, 2) != size(output, 2) &&
            throw("input and output must have the same number of examples")

        in_type = eltype(input)
        out_type = eltype(output)
        target_type = ndims(output) == 1 ? Vector : Matrix
        extras_type = extras === nothing ? Nothing : Dict{String, Any}

        # check input column names
        if extras !== nothing && "column-names-attributes" in keys(extras)
            input_names = [Symbol(name) for name in extras["column-names-attributes"]]
        else
            input_names = [Symbol("A$(i)") for i in 1:size(input, 1)]
        end

        length(input_names) != size(input, 1) && 
            throw("number of attribute names does not match the number of attributes")

        # check output/target column names
        if extras !== nothing && "column-names-target" in keys(extras)
            output_names = [Symbol(name) for name in extras["column-names-target"]]
        elseif size(output, 1) > 1
            output_names = [Symbol("label$(i)") for i in 1:size(output, 1)]
        else
            output_names = [:label]
        end

        length(output_names) != size(output, 1) &&
            throw("number of output labels does not match the number of outputs")

        new{in_type, out_type, extras_type}(input, output, metadata, extras, input_names, output_names)
    end
end

function TabularDataset(name::AbstractString, split=:train)
    name = lowercase(name)
    name ∉ keys(_metadata) && throw("Unknown dataset `$name`")

    data_dict = npzread(
        joinpath(@artifact_str("$name-npz"), "$name.npz"),
        ["$split-data", "$split-labels"]
    )

    input = transpose(data_dict["$split-data"])
    output = transpose(data_dict["$split-labels"])
    metadata = _metadata[name]
    extras = haskey(metadata, "extras_location") ? metadata["extras_location"] : nothing

    return TabularDataset(input, output, metadata, extras)
end

# "basic" getters and info
num_examples(ds::TabularDataset) = size(ds.input, 2)
num_inputs(ds::TabularDataset) = size(ds.input, 1)
num_outputs(ds::TabularDataset) = size(ds.output, 1)

task(ds::TabularDataset) = ds.metadata["task"]
num_classes(ds::TabularDataset) =
    if task(ds) != "classification"
        throw("non-classification datasets don't have a number of classes")
    else
        return ds.metadata["classes"]
    end

has_extras(ds::TabularDataset) = ds.extras !== nothing
has_extra(ds::TabularDataset, extra_name) = has_extras(ds) && extra_name in keys(ds.extras)

categorical_attributes(ds::TabularDataset) =
    has_extra(ds, "categories") ? keys(ds.extras["categories"]) : nothing

license(ds::TabularDataset) = has_extra(ds, "license") ? ds.extras["license"] : nothing
bibtex(ds::TabularDataset) = has_extra(ds, "bibtex") ? ds.extras["bibtex"] : nothing

# indexing and iteration protocol on the dataset itself
Base.getindex(ds::TabularDataset) = (ds.input, ds.output)
Base.getindex(ds::TabularDataset, i) = (ds.input[:, i], ds.output[:, i])
Base.firstindex(ds::TabularDataset) = 1
Base.lastindex(ds::TabularDataset) = length(ds)
Base.length(ds::TabularDataset) = num_examples(ds)

IndexStyle(::Type{TabularDataset}) = IndexLinear()

#Base.eltype(::Type{TabularDataset}) = Tuple{Vector, Vector}

# Tables.jl interface
Tables.istable(::Type{TabularDataset}) = true
Tables.rowaccess(::Type{TabularDataset}) = true
Tables.columnaccess(::TabularDataset) = true
Tables.columnnames(ds::TabularDataset) = vcat(ds.input_names, ds.output_names)

Tables.schema(ds::TabularDataset) = Tables.Schema{nothing, nothing}(
    vcat(ds.input_names, ds.output_names),
    vcat(repeat([eltype(ds.input)], num_inputs(ds)), repeat([eltype(ds.output)], num_outputs(ds)))
)

# rows interface
struct TabularDatasetRow{DatasetType <: TabularDataset}
    ds::DatasetType
    name_indices::Dict{Symbol, Int}
    index::Int
end

Tables.columnnames(row::TabularDatasetRow) = vcat(row.ds.input_names, row.ds.output_names)
function Tables.getcolumn(row::TabularDatasetRow, i::Int)
    if i > num_inputs(row.ds)
        return row.ds.output[i - num_inputs(row.ds), ds.index]
    else
        return row.ds.input[i, ds.index]
    end
end
Tables.getcolumn(row::TabularDatasetRow, nm::Symbol) = (println(row.name_indices[nm]); Tables.getcolumn(row, row.name_indices[nm]))
Tables.getcolumn(row::TabularDatasetRow, ::Type, i::Int, ::Symbol) = Tables.getcolumn(row, i)

struct TabularDatasetRows{DatasetType <: TabularDataset}
    ds::DatasetType
    name_indices::Dict{Symbol, Int}
end

function Base.iterate(iter::TabularDatasetRows, row_num=1)
    if row_num > num_examples(iter.ds)
        return nothing
    else
        return TabularDatasetRow{typeof(iter.ds)}(iter.ds, iter.name_indices, row_num), row_num + 1
    end
end

function Tables.rows(ds::TabularDataset)
    all_names = vcat(ds.input_names, ds.output_names)
    return TabularDatasetRows{typeof(ds)}(ds, Dict(name => index for (index, name) in enumerate(all_names)))
end

# column interface
Tables.columns(ds::TabularDataset) = ds
function Tables.getcolumn(ds::TabularDataset, i::Int)
    if i > num_inputs(ds)
        return ds.output[i - num_inputs(ds), :]
    else
        return ds.input[i, :]
    end
end
function Tables.getcolumn(ds::TabularDataset, nm::Symbol)
    index = findfirst(==(nm), ds.input_names)
    if index !== nothing
        return ds.input[index, :]
    else
        return ds.output[findfirst(==(nm), ds.output_names), :]
    end
end
Tables.getcolumn(ds::TabularDataset, ::Type, i::Int, ::Symbol) = Tables.getcolumn(ds, i)
