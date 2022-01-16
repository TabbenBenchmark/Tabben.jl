using Tabben: num_examples, num_inputs, num_outputs, num_classes, task,
has_extras, has_extra

@testset "classification dataset tests" begin
    ns = [5, 10, 17, 100, 1000]
    ms = [5, 10, 17, 100, 1000, 5000]
    ks = [1, 2, 3, 5, 10]
    cs = [2, 3, 5, 10, 100]

    for n in ns, m in ms, k in ks, c in cs
        ds = random_classification_dataset(n, m, k, c)

        @test num_examples(ds) == n
        @test num_inputs(ds) == m
        @test num_outputs(ds) == k
        @test num_classes(ds) == c

        @test task(ds) == "classification"

        @test has_extras(ds)

        for extra_name in ("license", "bibtex", "column-names-attributes", "column-names-target")
            @test has_extra(ds, extra_name)
        end
        @test !has_extra(ds, "other")
        @test !has_extra(ds, "blah")
    end

end

