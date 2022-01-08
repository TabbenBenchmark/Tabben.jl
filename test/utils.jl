
function random_classification_dataset(n, m, k, c)
    input = rand(n, m)
    output = rand(1:c, k, m)
    metadata = Dict(
        task => "classification",
        classes => c,
        bibtex => "test bibtex",
    )


end
