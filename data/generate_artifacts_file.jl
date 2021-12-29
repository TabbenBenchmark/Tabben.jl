using ArtifactUtils, Artifacts, TOML


function add_all_artifacts(metadata)
    for (name, data) in metadata
        println("Adding artifacts for $(name)")

        # add an artifact for the dataset file
        add_artifact!(
            "../Artifacts.toml",
            "$(name)-npz",
            string(data["data_location"], ".tar.gz"),
            clear=false,
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

metadata = TOML.parsefile("data.toml")
add_all_artifacts(metadata)