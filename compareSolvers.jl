using MPIFiles, MPIReco, BenchmarkTools
using MPIReco.LinearOperatorCollection
include("config.jl")

sf = MultiMPIFile([joinpath(datadir, "SF$i$sm_suffix.mdf") for i = 1:4])
meas = MPIFile(joinpath(datadir, "measStatic.mdf"))
grid = (49, 49, 28)

params = Dict{Symbol, Any}()
# Measurement and system matrix loading/preprocessing
params[:SNRThresh] = 2
params[:minFreq] = 80e3
params[:sf] = sf
params[:recChannels] = 1:3
params[:tfCorrection] = false
params[:mapping] = collect(1:4)


params[:reg] = [L2Regularization(0.01)]
params[:regTrafo] = [opEye(ComplexF32, prod(grid), S = typeof(gpu(rand(ComplexF32, 1)))) for i = 1:2]
params[:rho] = 5.0e-5
params[:iterationsCG] = 4


variants = [(cpu, Kaczmarz, 3), (gpu, CGNR, 30), (gpu, ADMM, 30)]
recos = Dict{String, Array{Float32, 3}}()

for (type, solver, iterations) in variants
  @info "Reco $solver with $iterations iterations on $type data"
  params[:arrayType] = type
  params[:solver] = solver
  params[:iterations] = iterations

  # Operator loading is cached, the benchmark mostly considers the inverse problem
  c = reconstruct("./reco.toml", meas; params...)
  recos[string(solver)] = Array(c[1, :, :, :, 1])
end

if save_results
  using HDF5
  mkpath(joinpath(resultdir, "data"))
  h5open(joinpath(resultdir, "data", "solvers.h5"), "w") do file
    for (type, solver, iterations) in variants
      write(file, "$(string(solver))/$(string(type))/image", recos[string(solver)])
    end
  end
end