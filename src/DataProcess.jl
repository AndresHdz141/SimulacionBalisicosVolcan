module DataProcess
using.. Objects
#Generar graficas y procesar datos (funciones)
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays

export PlotGraph, GridImpactProbability3D, CellSurfaceAreas, PlotImpactMap3D, AggregateGrid, AggregateCoords

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

function GridImpactProbability3D(all_projectiles_data::Vector{ProyectileData}, volcan)
    N  = length(all_projectiles_data)
    nx = length(volcan.x_coords)
    ny = length(volcan.y_coords)
    n_ij = zeros(Int, nx, ny)

    x_ref = volcan.x_coords[1]
    y_ref = volcan.y_coords[1]
    ps    = volcan.pixel_size

    fuera_dominio = 0

    for p in all_projectiles_data
        x, y, _ = p.pos[end]   
        i = floor(Int, (x - x_ref) / ps) + 1
        j = floor(Int, (y - y_ref) / ps) + 1
        if i < 1 || i > nx || j < 1 || j > ny
            fuera_dominio += 1
            continue
        end
        n_ij[i, j] += 1
    end

    if fuera_dominio > 0
        println("Aviso: ", fuera_dominio, " de ", N,
                " impactos cayeron fuera del dominio del DEM y no se contabilizaron.")
    end

    P_ij = n_ij ./ N
    return n_ij, P_ij
end

function CellSurfaceAreas(volcan)
    z  = volcan.z_matrix
    ny, nx = size(z)
    p  = Float64(volcan.pixel_size)
    A  = fill(p^2, nx, ny)

    for i in 2:nx-1, j in 2:ny-1
        dhdx = (z[j, i+1] - z[j, i-1]) / (2p)
        dhdy = (z[j+1, i] - z[j-1, i]) / (2p)
        A[i, j] = p^2 * sqrt(1 + dhdx^2 + dhdy^2)
    end
    return A
end

function AggregateGrid(n_ij::Matrix{Int}, A_ij::Matrix{Float64}, block_size::Int)
    nx, ny = size(n_ij)
    NX = cld(nx, block_size)
    NY = cld(ny, block_size)

    n_IJ = zeros(Int, NX, NY)
    A_IJ = zeros(Float64, NX, NY)

    for i in 1:nx, j in 1:ny
        I = cld(i, block_size)
        J = cld(j, block_size)
        n_IJ[I, J] += n_ij[i, j]
        A_IJ[I, J] += A_ij[i, j]
    end

    return n_IJ, A_IJ
end

function AggregateCoords(coords::AbstractRange, block_size::Int)
    return collect(coords[1:block_size:length(coords)])
end

function PlotImpactMap3D(x_coords, y_coords, z_matrix::AbstractMatrix{<:Real}, values::AbstractMatrix{<:Real}; label::String = "P_ij = n_ij / N", colormap = :inferno)
    fig = Figure()
    ax = Axis3(fig[1, 1], title = "Mapa 3D de probabilidad de impacto",
               xlabel = "X (m)", ylabel = "Y (m)", zlabel = "Elevación (m)")

    sf = surface!(ax, x_coords, y_coords, z_matrix',
                  color = values, colormap = colormap)

    Colorbar(fig[1, 2], sf, label = label)
    display(fig)
    return fig
end

end