module DataProcess
#Generar graficas y procesar datos (funciones)
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays

export PlotGraph

function PlotGraph(data)
fig = Figure()
ax = Axis3(fig[1, 1], title = "Multiple 3D Data Sets",
           xlabel = "X", ylabel = "Y", zlabel = "Z")
for vector in data
lines!(ax, vector.pos)
end
display(fig)
end

function ImpactProbability(xp::Vector{Float64}, yp::Vector{Float64}, xmin::Float64, xmax::Float64, ymin::Float64, nx::Int, ny::Int)

    N = length(xp)

    b = (xmax - xmin)/nx
    h = (ymax - ymin)/ny

    n_ij = zeros(Int, nx, ny)

    for k in 1:N
        i = round(Int, (xp[k] - xmin)/b)
        j = round(Int, (yp[k] - ymin)/h)
        i = clamp(i, 1, nx)
        j = clamp(j, 1, ny)
        n_ij[i, j] += 1
    end

    P_ij = n_ij ./ N

    return n_ij, P_ij
end
end