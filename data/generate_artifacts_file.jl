using ArtifactUtils, Artifacts, TOML


function add_all_artifacts()
    artifacts_file = abspath(joinpath(@__DIR__, "..", "Artifacts.toml"))

    metadata_hash = add_artifact!(
        artifacts_file,
        "metadata",
        "https://github.com/umd-otb/OpenTabularDataBenchmark/releases/download/v0.0.7-pre/data.toml.tar.gz",
        force=true,
    )

    metadata = TOML.parsefile(joinpath(artifact_path(metadata_hash), "data.toml"))

    for (name, data) in metadata
        println("Adding artifacts for $(name)")

        # add an artifact for the dataset file
        add_artifact!(
            "../Artifacts.toml",
            "$(name)-npz",
            string(data["data_location"], ".tar.gz"),
            lazy=true,
            force=true
        )

        # add an artifact for the extras file if present
        if "extras_location" in keys(data)
            add_artifact!(
                "../Artifacts.toml",
                "$(name)-extras",
                string(data["extras_location"], ".tar.gz"),
                lazy=true,
                force=true
            )
        end
    end
end

add_all_artifacts()
