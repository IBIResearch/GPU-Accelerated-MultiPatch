using HDF5, CairoMakie, Colors

Makie.update_theme!(fonts = (regular = Makie.texfont(), bold = Makie.texfont(:bold), italic = Makie.texfont(:italic)))

colors = [RGB(178/255, 34/255, 41/255), RGB(104/255, 195/255, 205/255), RGB(138/255, 189/255, 36/255), RGB(239/255, 123/255, 5/255), RGB(87/255,87/255,86/255), RGB(0/255,73/255,146/255)]
mkpath(joinpath(resultdir, "figures"))

solverfile = joinpath(resultdir, "data", "solvers.h5")
if isfile(solverfile)
  fig = Figure(backgroundcolor = :transparent)

  h5open(solverfile) do file
    solvers = keys(file)

    limit = maximum(map(s -> maximum(file[s][first(keys(file[s]))]["image"][]), solvers))

    for (i, solver) in enumerate(solvers)
      type = first(keys(file[solver]))
      Box(fig[1, i], color = (colors[i], 0.2), cornerradius = 15, strokecolor = colors[i])
      axRecoCGNR = CairoMakie.Axis(fig[1, i], alignmode = Outside(10), height = 150, width = 150, xlabelpadding = 7, title = solver)
      hidedecorations!(axRecoCGNR, label = false)
      heatmap!(axRecoCGNR, maximum(file[solver][type]["image"][], dims = 3)[:, :, 1])#, colorrange = (0, limit))
      #Colorbar(fig[1, 4], label = "Signal Intensity / a.u.")

    end
  end
  resize_to_layout!(fig)
  save(joinpath(resultdir, "figures", "solvers.pdf"), fig)

  fig
end