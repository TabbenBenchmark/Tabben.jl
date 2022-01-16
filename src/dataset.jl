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

    function TabularDataset(input, output, metadata, extras=nothing)
        ndims(input) != 2 && throw("input must have exactly 2 dimensions")
        ndims(output) ∉ 2 && throw("output must have 2 dimensions")
        size(input, 2) != size(output, 2) &&
            throw("input and output must have the same number of examples")

        in_type = eltype(input)
        out_type = eltype(output)
        target_type = ndims(output) == 1 ? Vector : Matrix
        extras_type = extras === nothing ? Nothing : Dict{String, Any}

        new{in_type, out_type, extras_type}(input, output, metadata, extras)
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



