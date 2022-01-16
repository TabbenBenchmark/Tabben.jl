using LazyArtifacts
using NPZ
using TOML

const _metadata = TOML.parsefile(joinpath(artifact"metadata", "data.toml"))
const datasets = keys(_metadata)


struct OpenTabularDataset{
        DataElType <: Number,
        TargetElType <: Number,
        ExtrasType <: Union{Dict{String, Any},Nothing}
    }

    input::Matrix{DataElType}
    output::Matrix{TargetElType}
    metadata::Dict{String, Any}
    extras::ExtrasType

    function OpenTabularDataset(input, output, metadata, extras=nothing)
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

function OpenTabularDataset(name::AbstractString, split=:train)
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

    return OpenTabularDataset(input, output, metadata, extras)
end

# "basic" getters and info
num_examples(ds::OpenTabularDataset) = size(ds.input, 2)
num_inputs(ds::OpenTabularDataset) = size(ds.input, 1)
num_outputs(ds::OpenTabularDataset) = size(ds.output, 1)

task(ds::OpenTabularDataset) = ds.metadata["task"]
num_classes(ds::OpenTabularDataset) =
    if task(ds) != "classification"
        throw("non-classification datasets don't have a number of classes")
    else
        return ds.metadata["classes"]
    end

has_extras(ds::OpenTabularDataset) = ds.extras !== nothing
has_extra(ds::OpenTabularDataset, extra_name) = has_extras(ds) && extra_name in keys(ds.extras)

categorical_attributes(ds::OpenTabularDataset) =
    has_extra(ds, "categories") ? keys(ds.extras["categories"]) : nothing

license(ds::OpenTabularDataset) = has_extra(ds, "license") ? ds.extras["license"] : nothing
bibtex(ds::OpenTabularDataset) = has_extra(ds, "bibtex") ? ds.extras["bibtex"] : nothing

# indexing and iteration protocol on the dataset itself
Base.getindex(ds::OpenTabularDataset) = (ds.input, ds.output)
Base.getindex(ds::OpenTabularDataset, i) = (ds.input[:, i], ds.output[:, i])
Base.firstindex(ds::OpenTabularDataset) = 1
Base.lastindex(ds::OpenTabularDataset) = length(ds)
Base.length(ds::OpenTabularDataset) = num_examples(ds)

IndexStyle(::Type{OpenTabularDataset}) = IndexLinear()

#Base.eltype(::Type{OpenTabularDataset}) = Tuple{Vector, Vector}

