using Tabben: num_examples, num_inputs, num_outputs, num_classes, task,
has_extras, has_extra, license, bibtex

@testset "classification dataset tests" begin
    ns = [5, 10, 17, 100, 1000]
    ms = [5, 10, 17, 100, 1000, 5000]
    ks = [1, 2, 3, 5, 10]
    cs = [2, 3, 5, 10, 100]

    for n in ns, m in ms, k in ks, c in cs
        ds = random_classification_dataset(n, m, k, c)

        @test num_examples(ds) == n == length(ds) == lastindex(ds)
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

        @test license(ds) == "test license"
        @test bibtex(ds) == "test bibtex"

        count = 0
        for i in 1:length(ds)
            single_input, single_output = ds[i]

            @test length(single_input) == m
            @test length(single_output) == k
            @test all(val in 0:c-1 for val in single_output)

            count += 1
        end
        @test count == n

        count = 0
        for (single_input, single_output) in ds
            @test length(single_input) == m
            @test length(single_output) == k
            @test all(val in 0:c-1 for val in single_output)

            count += 1
        end
        @test count == n
    end

end

