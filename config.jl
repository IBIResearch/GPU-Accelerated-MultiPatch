##### Download options #####
small_sm = true                         # If small system matrices should be downloaded (~ 4x230 MB)
large_sm = true                         # If large system matrices should be downloaded (~ 4x2.2 GB)
downdir = joinpath(@__DIR__(), "data")  # Where the files should be downloaded to. Files will only be downloaded if they aren't found in the `downdir`

##### Reconstruction options #####
datadir = downdir                       # From where the measurement and system matrices 
sm_suffix = "Large" # "Small"           # If the "Large" or "Small" system matrices should be used for reconstructions

SNRThresh = 2                           # SNR threshold to be used for reconstruction. Increase to reduce the GPU usage.
                                        # Threshold of 3 requires around 8 GB, 5 around 7 GB. Can impact reconstruction results

##### Benchmark options #####
trials = 20                             # How many trials to use in a benchmark 

##### GPU backend #####
cpu = Array
# Which GPU backend should be used for reconstruction
# For further installation helps consult the documentation of the respective GPU packages:
# NVIDIA: https://cuda.juliagpu.org/
# Metal:  https://metal.juliagpu.org/ 
# AMD:    https://amdgpu.juliagpu.org/

# No GPU
# gpu = cpu

# NVIDIA GPU (CUDA):
using CUDA
gpu = CuArray

# MacOS GPU (Metal):
# using Metal
# gpu = MtlArray

# AMD GPU (ROCm):
# using AMDGPU
# gpu = ROCArray

##### Result Handling #####
resultdir = joinpath(@__DIR__(), "result") # Where the result data and figures should be stored
save_results = true                     # If results should be saved as a HDF5
make_figures = true