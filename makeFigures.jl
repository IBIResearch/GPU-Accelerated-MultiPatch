using HDF5, CairoMakie
mkpath(joinpath(resultdir, "figures"))
colors = [:red, :blue]

solverfile = joinpath(resultdir, "data", "solver.h5")
if isfile(solverfile)
  kaczTimes = h5read(solverfile, "Kaczmarz/$cpu/times")
  cgnrTimes = h5read(solverfile, "CGNR/$gpu/times")

  fig = Figure()
  ax = CairoMakie.Axis(fig[1, 1], title = "Runtime Benchmark", xticks = ([0, 1], ["Kaczmarz", "CGNR"]), ylabel = "Runtime / s", height = 150, width = 150)
  rainclouds!(ax, fill(0, length(kaczTimes)), kaczTimes, color = colors[1], plot_boxplots = false, side = :left)
  rainclouds!(ax, fill(1, length(cgnrTimes)), cgnrTimes, color = colors[2], plot_boxplots = false, side = :right)

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

  Label(fig[1, 2:3, Top()], "Reconstruction Results (MIP)", font = :bold, padding = (0, 0, 4, 0))

  resize_to_layout!(fig)
  save(joinpath(resultdir, "figures", "solver.pdf"), fig)
end

operatorfile = joinpath(resultdir, "data", "operator.h5")
if isfile(operatorfile)
  timesForwardCPU = h5read(operatorfile, "forward/$cpu")
  timesForwardGPU = h5read(operatorfile, "forward/$gpu")
  timesAdjointCPU = h5read(operatorfile, "adjoint/$cpu")
  timesAdjointGPU = h5read(operatorfile, "adjoint/$gpu")

  fig = Figure()
  ax = CairoMakie.Axis(fig[1, 1], title = "CPU", xticks = ([0, 1], ["Forward", "Adjoint"]), ylabel = "Runtime / s", height = 150, width = 150)
  rainclouds!(ax, fill(0, length(timesAdjointCPU)), timesForwardCPU, color = colors[1], plot_boxplots = false, side = :left)
  ax2 = CairoMakie.Axis(fig[1, 1], xticks = ([0, 1], ["Forward", "Adjoint"]), height = 150, width = 150, yaxisposition = :right)
  hidespines!(ax2)
  hidexdecorations!(ax2)
  linkxaxes!(ax, ax2)
  vlines!(ax, 0.5, color = :black)
  rainclouds!(ax2, fill(1, length(timesAdjointCPU)), timesAdjointCPU, color = colors[1], plot_boxplots = false, side = :right)

  
  ax = CairoMakie.Axis(fig[1, 2], title = "GPU", xticks = ([0, 1], ["Forward", "Adjoint"]), height = 150, width = 150)
  rainclouds!(ax, fill(0, length(timesAdjointGPU)), timesForwardGPU, color = colors[2], plot_boxplots = false, side = :left)
  rainclouds!(ax, fill(1, length(timesAdjointGPU)), timesAdjointGPU, color = colors[2], plot_boxplots = false, side = :right)


  resize_to_layout!(fig)
  save(joinpath(resultdir, "figures", "operator.pdf"), fig)
end