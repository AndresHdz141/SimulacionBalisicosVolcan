module DataProcess
using ..Objects
#Generar graficas y procesar datos (funciones)
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays

export PlotGraph

function PlotGraph(data, volcan)
    fig = Figure()
    ax = Axis3(fig[1, 1], title = "Trayectorias de Proyectiles 3D",
            xlabel = "X (m)", ylabel = "Y (m)", zlabel = "Z (m)")
        for vector in data
        scatter!(ax, vector.pos, color = :black, alpha = 0.5, markersize = 0.5)
        end
    surface!(ax,volcan.x_coords, volcan.y_coords, volcan.z_matrix', colormap = :terrain)
    display(fig)
end





end