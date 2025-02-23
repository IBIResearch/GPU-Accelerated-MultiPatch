using HDF5, CairoMakie, Colors

Makie.update_theme!(fonts = (regular = Makie.texfont(), bold = Makie.texfont(:bold), italic = Makie.texfont(:italic)))

colors = [RGB(178/255, 34/255, 41/255), RGB(104/255, 195/255, 205/255), RGB(138/255, 189/255, 36/255), RGB(239/255, 123/255, 5/255), RGB(87/255,87/255,86/255), RGB(0/255,73/255,146/255)]
mkpath(joinpath(resultdir, "figures"))

operatorfile = joinpath(resultdir, "data", "operator.h5")
if isfile(operatorfile)
  timesForwardCPU = h5read(operatorfile, "forward/$cpu")
  timesForwardGPU = h5read(operatorfile, "forward/$gpu")
  timesAdjointCPU = h5read(operatorfile, "adjoint/$cpu")
  timesAdjointGPU = h5read(operatorfile, "adjoint/$gpu")

  fig = Figure()
  ax = CairoMakie.Axis(fig[1, 1], title = "CPU", xticks = ([0, 1], ["Forward", "Adjoint"]), ylabel = "Runtime / s", height = 150, width = 150)
  rainclouds!(ax, fill(0, length(timesAdjointCPU)), timesForwardCPU, color = colors[2], plot_boxplots = false, side = :left)
  ax2 = CairoMakie.Axis(fig[1, 1], xticks = ([0, 1], ["Forward", "Adjoint"]), height = 150, width = 150, yaxisposition = :right)
  hidespines!(ax2)
  hidexdecorations!(ax2)
  linkxaxes!(ax, ax2)
  vlines!(ax, 0.5, color = :black)
  rainclouds!(ax2, fill(1, length(timesAdjointCPU)), timesAdjointCPU, color = colors[2], plot_boxplots = false, side = :right)

  
  ax = CairoMakie.Axis(fig[1, 2], title = "GPU", xticks = ([0, 1], ["Forward", "Adjoint"]), height = 150, width = 150)
  rainclouds!(ax, fill(0, length(timesAdjointGPU)), timesForwardGPU, color = colors[3], plot_boxplots = false, side = :left)
  rainclouds!(ax, fill(1, length(timesAdjointGPU)), timesAdjointGPU, color = colors[3], plot_boxplots = false, side = :right)


  resize_to_layout!(fig)
  save(joinpath(resultdir, "figures", "operator.pdf"), fig)
  fig
end