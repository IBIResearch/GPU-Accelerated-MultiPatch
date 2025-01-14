using HTTP
include("config.jl")
function downloadData(filenameServer, filenameLocal)
  if !isfile(filenameLocal)
    @info "download $(filenameLocal)..."
    HTTP.open("GET", "http://media.tuhh.de/ibi/openMPIData/data/"*filenameServer) do http
      open(filenameLocal, "w") do file
        write(file, http)
      end
    end
  end
end

mkpath("./data/")

# Download data

downloadData("measurements/rotationPhantom/3.mdf", joinpath(downdir, "measBG.mdf"))
downloadData("measurements/rotationPhantom/4.mdf", joinpath(downdir, "measStatic.mdf"))

# Small SF
downloadData("calibrations/12.mdf", joinpath(downdir, "SF1Small.mdf"))
downloadData("calibrations/13.mdf", joinpath(downdir, "SF2Small.mdf"))
downloadData("calibrations/14.mdf", joinpath(downdir, "SF3Small.mdf"))
downloadData("calibrations/15.mdf", joinpath(downdir, "SF4Small.mdf"))
# Large SF
downloadData("calibrations/8.mdf", joinpath(downdir, "SF1Large.mdf"))
downloadData("calibrations/9.mdf", joinpath(downdir, "SF2Large.mdf"))
downloadData("calibrations/10.mdf", joinpath(downdir, "SF3Large.mdf"))
downloadData("calibrations/11.mdf", joinpath(downdir, "SF4Large.mdf"));