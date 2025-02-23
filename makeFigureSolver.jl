using HDF5, CairoMakie, Colors

Makie.update_theme!(fonts = (regular = Makie.texfont(), bold = Makie.texfont(:bold), italic = Makie.texfont(:italic)))

colors = [RGB(178/255, 34/255, 41/255), RGB(104/255, 195/255, 205/255), RGB(138/255, 189/255, 36/255), RGB(239/255, 123/255, 5/255), RGB(87/255,87/255,86/255), RGB(0/255,73/255,146/255)]
mkpath(joinpath(resultdir, "figures"))

solverfile = joinpath(resultdir, "data", "solver.h5")
if isfile(solverfile)
  kaczTimes = h5read(solverfile, "Kaczmarz/$cpu/times")
  cgnrTimes = h5read(solverfile, "CGNR/$gpu/times")

  fig = Figure()
  ax = CairoMakie.Axis(fig[1, 1], title = "Runtime Benchmark", xticks = ([0, 1], ["Kaczmarz\n(CPU)", "CGNR\n(GPU)"]), ylabel = "Runtime / s", height = 150, width = 150)
  rainclouds!(ax, fill(0, length(kaczTimes)), kaczTimes, color = colors[2], show_median = false, plot_boxplots = false, side = :left)
  rainclouds!(ax, fill(1, length(cgnrTimes)), cgnrTimes, color = colors[3], show_median = false, plot_boxplots = false, side = :right)

  kaczReco = h5read(solverfile, "Kaczmarz/$cpu/image")
  cgnrReco = h5read(solverfile, "CGNR/$gpu/image")
  limit = max(maximum(kaczReco), maximum(cgnrReco))
  # MIP along z-axis 
  axRecoKacz = CairoMakie.Axis(fig[1, 2], height = 150, width = 150, xlabelpadding = 7, xlabel = "Kaczmarz")
  hidedecorations!(axRecoKacz, label = false)
  heatmap!(axRecoKacz, maximum(kaczReco, dims = 3)[:, :, 1], colorrange = (0, limit))
  
  axRecoCGNR = CairoMakie.Axis(fig[1, 3], height = 150, width = 150, xlabelpadding = 7, xlabel = "CGNR")
  hidedecorations!(axRecoCGNR, label = false)
  heatmap!(axRecoCGNR, maximum(cgnrReco, dims = 3)[:, :, 1], colorrange = (0, limit))
  Colorbar(fig[1, 4], label = "Signal Intensity / a.u.")

  Label(fig[1, 2:3, Top()], "Reconstruction Results", font = :bold, padding = (0, 0, 4, 0))

  resize_to_layout!(fig)
  save(joinpath(resultdir, "figures", "solver.pdf"), fig)
  fig
end