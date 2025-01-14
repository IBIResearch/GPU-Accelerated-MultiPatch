using MPIFiles, MPIReco, BenchmarkTools
include("config.jl")

sf = MultiMPIFile([joinpath(datadir, "SF$i$sm_suffix.mdf") for i = 1:4])
meas = MPIFile(joinpath(datadir, "measStatic.mdf"))

params = Dict{Symbol, Any}()
# Measurement and system matrix loading/preprocessing
params[:SNRThresh] = 2
params[:minFreq] = 80e3
params[:sf] = sf
params[:recChannels] = 1:3
params[:tfCorrection] = false

# Shared reconstruction parameter
params[:reg] = [L2Regularization(0.01)]

variants = [(cpu, Kaczmarz, 3), (gpu, CGNR, 30)]
recos = Dict{String, Array{Float32, 3}}()
times = Dict{String, Vector{Float32}}()
for (type, solver, iterations) in variants
  @info "Benchmark $solver with $iterations iterations on $type data"
  params[:arrayType] = type
  params[:solver] = solver
  params[:iterations] = iterations

  # Operator loading is cached, the benchmark mostly considers the inverse problem
  c = reconstruct("./reco.toml", meas; params...)
  result = @benchmark reconstruct("./reco.toml", $meas; $params...) seconds = (60 * 15) samples = trials evals = 1
  recos[string(solver)] = Array(c[1, :, :, :, 1])
  times[string(solver)] = result.times ./ 1e9 # Store in /s
end

if save_results
  using HDF5
  mkpath(joinpath(resultdir, "data"))
  h5open(joinpath(resultdir, "data", "solver.hd5"), "w") do file
    for (type, solver, iterations) in variants
      write(file, "$(string(solver))/$(string(type))/image", recos[string(solver)])
      write(file, "$(string(solver))/$(string(type))/times", times[string(solver)])
    end
  end
end


#cStatic = reconstructionMultiPatch(sf, meas, bgCorrection=false,
#			      SNRThresh=2, minFreq=80e3,recChannels=[1,2,3], 
#                              reg= [L2Regularization(0.01)], iterations=3)