using HDF5, CairoMakie, Colors

Makie.update_theme!(fonts = (regular = Makie.texfont(), bold = Makie.texfont(:bold), italic = Makie.texfont(:italic)))

colors = [RGB(178/255, 34/255, 41/255), RGB(104/255, 195/255, 205/255), RGB(138/255, 189/255, 36/255), RGB(239/255, 123/255, 5/255), RGB(87/255,87/255,86/255), RGB(0/255,73/255,146/255)]
mkpath(joinpath(resultdir, "figures"))

solverfile = joinpath(resultdir, "data", "reg.h5")
if isfile(solverfile)
  fig = Figure(backgroundcolor = :transparent)

  h5open(solverfile) do file
    labels = keys(file)
    labelmap = Dict(
      "L1" => L"\lambda||\textbf{c}||_1",
      "L2" => L"\lambda||\textbf{c}||^2_2",
      "TV+L1" => L"\lambda_1||\textbf{c}||_1 + \lambda_2||\textbf{c}||_{\textbf{TV}}"
    )

    limit = maximum(map(s -> maximum(file[s][]), labels))

    Box(fig[1, 1:length(labels)], color = (colors[1], 0.2), cornerradius = 15, strokecolor = colors[1])
    for (i, label) in enumerate(labels)
      ax = CairoMakie.Axis(fig[1, i], alignmode = Outside(10), titlesize = 18, height = 150, width = 150, xlabelpadding = 7, title = get(labelmap, label, label))
      hidedecorations!(ax, label = false)
      heatmap!(ax, maximum(file[label][], dims = 3)[:, :, 1])#, colorrange = (0, limit))
      #Colorbar(fig[1, 4], label = "Signal Intensity / a.u.")

    end
  end
  resize_to_layout!(fig)
  save(joinpath(resultdir, "figures", "reg.pdf"), fig)

  fig
end