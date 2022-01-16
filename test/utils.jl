using Tabben: TabularDataset

function random_classification_dataset(n, m, k, c)
    input = rand(m, n)
    output = rand(1:c, k, n)
    metadata = Dict(
        "data_location" => "https://url/to/the/npz/file.npz",
        "extras_location" => "https://url/to/the/extras/file.json",
        "task" => "classification",
        "classes" => c,
    )
    extras = Dict(
        "license" => "test license",
        "bibtex" => "test bibtex",
        "column-names-attributes" => ["A$i" for i in 1:n],
        "column-names-target" => ["T$i" for i in 1:k]
    )

    return TabularDataset(input, output, metadata, extras)
end
