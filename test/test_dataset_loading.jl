using Tabben: TabularDataset, num_examples, num_classes, num_inputs, num_outputs
using Test

function test_dataset(dataset, n, m, k=1)
    @test num_examples(dataset) == n
    @test num_inputs(dataset) == m
    @test num_outputs(dataset) == k
end

@testset "adult" begin
    test_dataset(TabularDataset("adult", :train), 32_561, 14)
    test_dataset(TabularDataset("adult", :test), 16_281, 14)
end

@testset "amazon" begin
    test_dataset(TabularDataset("amazon", :train), 26_215, 9)
    test_dataset(TabularDataset("amazon", :test), 6_554, 9)
end

@testset "arcene" begin
    test_dataset(TabularDataset("arcene", :train), 100, 10_000)
    test_dataset(TabularDataset("arcene", :test), 100, 10_000)
end

@testset "covertype" begin
    test_dataset(TabularDataset("covertype", :train), 11_340, 54)
    test_dataset(TabularDataset("covertype", :valid), 3_780, 54)
    test_dataset(TabularDataset("covertype", :test), 565_892, 54)
end

@testset "musk" begin
    test_dataset(TabularDataset("musk", :train), 5_548, 166)
    test_dataset(TabularDataset("musk", :test), 1_050, 166)
end

@testset "parkinsons" begin
    test_dataset(TabularDataset("parkinsons", :train), 4_646, 16, 2)
    test_dataset(TabularDataset("parkinsons", :test), 1_229, 16, 2)
end

@testset "poker" begin
    test_dataset(TabularDataset("poker", :train), 25_010, 10)
    test_dataset(TabularDataset("poker", :test), 1_000_000, 10)
end

@testset "rossman" begin
    test_dataset(TabularDataset("rossman", :train), 814_688, 18)
    test_dataset(TabularDataset("rossman", :test), 202_521, 18)
end
