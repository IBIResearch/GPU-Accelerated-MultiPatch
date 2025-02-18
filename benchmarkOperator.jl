using MPIFiles, MPIReco, BenchmarkTools
include("config.jl")

sf = MultiMPIFile([joinpath(datadir, "SF$i$sm_suffix.mdf") for i = 1:4])
meas = MPIFile(joinpath(datadir, "measStatic.mdf"))

# We do a reoncstruction with one iteration and then retrieve the operator from the algortihm struct
params = Dict{Symbol, Any}()
params[:SNRThresh] = 2
params[:minFreq] = 80e3
params[:sf] = sf
params[:recChannels] = 1:3
params[:tfCorrection] = false
params[:reg] = [L2Regularization(0.01)]
params[:solver] = Kaczmarz
params[:arrayType] = cpu
params[:iterations] = 1
params[:mapping] = collect(1:4)

using MPIReco.AbstractImageReconstruction
plan = loadPlan("./reco.toml", [AbstractImageReconstruction, MPIFiles, MPIReco])
setAll!(plan, params)
algo = build(plan)
reconstruct(algo, meas)
op = algo.ffOp

# Load preprocessed measurement data
u = AbstractImageReconstruction.process(algo, algo.params.pre, meas, algo.freqs)
u = vec(u[:, :, 1]) # just first frame

# Now we adapt and move operator and measurement data to the GPU
using Adapt
op_gpu = adapt(gpu, op)
u_gpu = adapt(gpu, u)

tmp = adjoint(op) * u
tmp_gpu = adjoint(op_gpu) * u_gpu
@assert isapprox(tmp, Array(tmp_gpu))
@assert isapprox(op * tmp, Array(op_gpu * tmp_gpu))

timesForwardCPU = @benchmark $op * $tmp seconds = (60 * 15) samples = trials evals = 1
timesForwardGPU = @benchmark $op_gpu * $tmp_gpu seconds = (60 * 15) samples = trials evals = 1
timesAdjointCPU = @benchmark $adjoint(op) * $u seconds = (60 * 15) samples = trials evals = 1
timesAdjointGPU = @benchmark $adjoint(op_gpu) * $u_gpu seconds = (60 * 15) samples = trials evals = 1

if save_results
  using HDF5
  mkpath(joinpath(resultdir, "data"))
  h5open(joinpath(resultdir, "data", "operator.h5"), "w") do file
    write(file, "forward/$cpu", timesForwardCPU.times ./ 1e9)
    write(file, "forward/$gpu", timesForwardGPU.times ./ 1e9)
    write(file, "adjoint/$cpu", timesAdjointCPU.times ./ 1e9)
    write(file, "adjoint/$gpu", timesAdjointGPU.times ./ 1e9)
  end
end