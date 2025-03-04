using HDF5, CairoMakie, Colors

Makie.update_theme!(fonts = (regular = Makie.texfont(), bold = Makie.texfont(:bold), italic = Makie.texfont(:italic)))

colors = [RGB(178/255, 34/255, 41/255), RGB(104/255, 195/255, 205/255), RGB(138/255, 189/255, 36/255), RGB(239/255, 123/255, 5/255), RGB(0/255,73/255,146/255)]
mkpath(joinpath(resultdir, "figures"))

operatorfile = joinpath(resultdir, "data", "backends.h5")
if isfile(operatorfile)
  fig = Figure(backgroundcolor = :transparent)

  h5open(operatorfile) do file
    backends = keys(file)
    backendMap = Dict(
      "CuArray" => "CUDA",
      "MtlArray" => "Metal",
      "ROCArray" => "AMD"
    )

    ax = CairoMakie.Axis(fig[1, 1], backgroundcolor = :transparent, title = "GPU Backends", xticks = (1:length(backends), map(backend -> get(backendMap, backend, backend), backends)), ylabel = "Average Speedup", height = 150, width = 150)


    for (i, backend) in enumerate(backends)
      timesForwardCPU = file[backend]["forward"]["$cpu"][]
      timesForwardGPU = file[backend]["forward"][backend][]
      timesAdjointCPU = file[backend]["adjoint"]["$cpu"][]
      timesAdjointGPU = file[backend]["adjoint"][backend][]

      incr_forward = mean(timesForwardCPU) / mean(timesForwardGPU)
      incr_adjoint = mean(timesAdjointCPU) / mean(timesAdjointGPU)

      cat = [i, i]
      dodge = [1, 2]
      height = [incr_forward, incr_adjoint]
      barplot!(ax, cat, height, dodge = dodge, color = colors[dodge .+ 3])
  
    end
    elements = [PolyElement(polycolor = x) for x in colors[[1, 2] .+ 3]]
    boxLegend = Legend(fig[1, 2], elements, ["Forward", "Adjoint"], orientation = :vertical, backgroundcolor = :transparent,)



    resize_to_layout!(fig)
    save(joinpath(resultdir, "figures", "backends.pdf"), fig)
  end
  fig
end