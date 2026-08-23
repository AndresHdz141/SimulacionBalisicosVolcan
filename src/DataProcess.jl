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

function ImpactProbability(xp::Vector{Float64}, yp::Vector{Float64}, xmin::Float64, xmax::Float64, ymin::Float64, ymax::Float64, nx::Int, ny::Int)

    N = length(xp)

    dx = (xmax - xmin)/nx
    dy = (ymax - ymin)/ny

    n_ij = zeros(Int, nx, ny)
    fuera_contorno = 0

    for k in 1:N
        if xp[k] < xmin || xp[k] >= xmax || yp[k] < ymin || yp[k] >= ymax
            fuera_contorno += 1
            continue
        end 
        i = round(Int, (xp[k] - xmin)/dx)
        j = round(Int, (yp[k] - ymin)/dy)
        i = clamp(i, 1, nx)
        j = clamp(j, 1, ny)
        n_ij[i, j] += 1
    end

    if fuera_contorno > 0
        println("Aviso: ", fuera_contorno, " proyectiles cayeron fuera del contorno de la malla y no se contabilizaron.")
    end

    P_ij = n_ij ./ N

    x_contorno = xmin:dx:xmax
    y_contorno = ymin:dy:ymax

    return n_ij, P_ij, x_contorno, y_contorno
end

function PlotImpact(P_ij::Matrix{Float64}, x_contorno, y_contorno)
    fig = Figure()
    ax = Axis(fig[1, 1], title = "Probabilidad de impacto por celda",
              xlabel = "X (m)", ylabel = "Y (m)", aspect = DataAspect())
    hm = heatmap!(ax, x_contorno, y_contorno, P_ij, colormap = :viridis)
    Colorbar(fig[1, 2], hm, label = "P_ij = n_ij / N")
    display(fig)
    return fig
end

end