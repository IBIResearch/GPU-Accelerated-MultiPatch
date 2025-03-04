using MPIFiles, MPIReco, BenchmarkTools
using MPIReco.LinearOperatorCollection
include("config.jl")

sf = MultiMPIFile([joinpath(datadir, "SF$i$sm_suffix.mdf") for i = 1:4])
meas = MPIFile(joinpath(datadir, "measStatic.mdf"))
grid = (49, 49, 28)

params = Dict{Symbol, Any}()
# Measurement and system matrix loading/preprocessing
params[:SNRThresh] = SNRThresh
params[:minFreq] = 80e3
params[:sf] = sf
params[:recChannels] = 1:3
params[:tfCorrection] = false
params[:mapping] = collect(1:4)
params[:iterations] = 30
params[:iterationsCG] = 4
params[:frames] = 1:5
params[:numAverages] = 5
params[:rho] = 1.0

variants = [("L2", [L2Regularization(0.3)]), ("L1", [L1Regularization(0.5)]), ("TV+L1",  [TVRegularization(0.1; shape = grid), L1Regularization(0.3)])]
recos = Dict{String, Array{Float32, 3}}()

for (label, reg) in variants
  params[:reg] = reg
  params[:regTrafo] = [opEye(ComplexF32, prod(grid), S = typeof(gpu(rand(ComplexF32, 1)))) for i = 1:length(reg)]
  params[:solver] = ADMM
  params[:arrayType] = gpu
  c = reconstruct("./reco.toml", meas; params...)
  recos[label] = Array(c[1, :, :, :, 1])
end

if save_results
  using HDF5
  mkpath(joinpath(resultdir, "data"))
  h5open(joinpath(resultdir, "data", "reg.h5"), "w") do file
    for (label, _) in variants
      write(file, "$label", recos[label])
    end
  end
end