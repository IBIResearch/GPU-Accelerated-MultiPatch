# GPU Accelerated Multi-Patch Reconstruction

This repository contains an example of GPU accelerated multi-patch processing using MPIReco.jl and an open-source multi-patch example from OpenMPIData.
The example produces similar results and plots as the ones presented in N. Hackelberg, M. Boberg and T. Knopp GPU Accelerated Multi-Patch Reconstruction.
Additionally, this example also showcases different solver and regularization terms and allows one to change the GPU backend.

## Installation

In order to use this code one first has to download [Julia](https://julialang.org/), clone this repository and navigate to the folder in the command line.
Afterwards one can start Julia and activate the [environment](https://pkgdocs.julialang.org/v1/environments/#Using-someone-else's-project) of the example.

This can be done with:
```julia
julia> using Pkg
julia> Pkg.activate(".")
```

By default the example includes the [CUDA.jl](https://cuda.juliagpu.org/stable/) package for working with NVIDIA cards. To change to a different GPU backend one has to add the respective Julia package (such as [Metal.jl](https://metal.juliagpu.org/) or [AMDGPU.jl](https://amdgpu.juliagpu.org/)) and change the used backend in the `config.jl` file. 

In general, these packages can be added with just:
```julia
julia> Pkg.add("Metal")
```
For more specific installation instructions we refer to the instructions of the respective packages.

Once the correct environment is activated we can use:
```julia
julia> Pkg.instantiate()
```
to make sure all packages are loaded. To download the OpenMPIData.jl enter:
```julia
julia> include("downloadData.jl")
```
in Julias REPL. The download location and size of the download system matrices can be changed in the `config.jl` file. Once the download is finished, we can execute a variety of benchmarks and comparisons.

## Execution
The example features five scripts comparing and benchmarking different aspects of multi-patch reconstruction. Each script can be executed by including it in the Julia REPL with for example:

```julia
julia> include("benchmarkOperator.jl")
```
In the `config.jl` file on can change the location where results are saved, the number of trials for runtime benchmarks and the GPU backend.

* `benchmarkOperators.jl`: This example compares the runtime of the multi-patch operator between CPU and GPU.
* `benchmarkSolvers.jl`: This example compares the runtime and reconstruction results between Kaczmarz and CGNR on CPU and GPU. Note that unlike the publication, this example does not produce any metrics for the solver iterations. To do this one would need to call the respective solver from [RegularizedLeastSquares.jl](https://juliaimagerecon.github.io/RegularizedLeastSquares.jl/latest/) with the operator directly and use a callback.
* `compareSolvers.jl`: This example compares several solver and processing unit combintations. The default combinations are Kaczmarz (CPU), CGNR (GPU) and ADMM (GPU).
* `compareRegTerms.jl`: This example compares several regularization terms using the ADMM solver on the GPU.
* `compareGPUBackends.jl`: This example is nearly identical to the `benchmarkOperators.jl` example, but differentiates the results results based on the used GPU backend. This allows one to aggregate results for different GPU backends.

The GPU operator requires around 6.5 GB of GPU memory and construction the operator requires a bit more. If the used GPU has enough memory, but runs out of memory when executing multiple scripts in the same session one can either restart Julia or try to use the garbage collection to reclaim memory.

The runtime benchmark, generally do not consider the first execution of a reconstruction or operator application. Julia is just-in-time compiled language and as such the first execution could potentially include the compilation time itself and not only the execution time. Additionally, MPIReco.jl by virtue of its underlying reconstruction framework AbstractImageReconstruction.jl allows for the caching of parts of a reconstruction. In particular, it can cache the loading of the system matrices and parts of the operator construction. Subsequent reconstructions are then mostly spending time in the solving of the inverse problem.

Each example produces a HDF5-file, which can then be used with the `makeFigureX.jl` files to visualize the results of the benchmarks.