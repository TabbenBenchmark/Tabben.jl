# Documentation for Tabben.jl

This is a Julia package for interfacing with the [Tabben](https://www.tabben.org/) benchmark for tabular data. It includes features for reading and working with the datasets and for standardized evaluation, but excludes functionality related to adding new datasets or validating dataset files (see the [Python package](https://umd-otb.github.io/OpenTabularDataBenchmark/) for that functionality).

You're currently looking at the docs for the Julia package. For documentation about the datasets themselves, see the [Datasets](https://umd-otb.github.io/OpenTabularDataBenchmark/datasets/) portion of the Python docs.

## Getting Started

You can install the latest stable version using the Julia package manager: 
```julia-pkg
(env) pkg> add Tabben
```

Everything for the data loading side revolves around the `OpenTabularDataset` struct. To get started, specify the "name" of the dataset (and other parameters if you want). Your local copy of the dataset will be stored in the usual place for artifacts in your Julia installation.
```julia
using Tabben: OpenTabularDataset

ds = OpenTabularDataset("arcene")  # defaults to the 'train' split
test_ds = OpenTabularDataset("arcene", :test)
```

To list all the available datasets, there's the `datasets` variable:
```julia
using Tabben: datasets

println(datasets)
```
