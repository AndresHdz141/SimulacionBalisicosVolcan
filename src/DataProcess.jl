module DataProcess
#Generar graficas y procesar datos (funciones)
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays

export PlotGraph

function PlotGraph(data)
fig = Figure()
ax = Axis3(fig[1, 1], title = "Trayectorias de Proyectiles 3D",
           xlabel = "X (m)", ylabel = "Y (m)", zlabel = "Z (m)")
for vector in data
lines!(ax, vector.pos)
end
display(fig)
end





end