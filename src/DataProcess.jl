module DataProcess
#Generar graficas y procesar datos (funciones)
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays

export PlotGraph, ImpactProbability, PlotImpact

function PlotGraph(data)
fig = Figure()
ax = Axis3(fig[1, 1], title = "Multiple 3D Data Sets",
           xlabel = "X", ylabel = "Y", zlabel = "Z")
for vector in data
lines!(ax, vector.pos)
end
display(fig)
end

end