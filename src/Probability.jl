module Probability
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays
using Makie.Colors
using Statistics

export PlotImpact

function ImpactProbability(xp::Vector{Float64}, yp::Vector{Float64},half_side::Float64, nx::Int, ny::Int)

    N = length(xp)

    x_contorno = range(-half_side,half_side, length = nx)
    y_contorno = range(-half_side,half_side, length = ny)

    dx = step(x_contorno)
    dy = step(y_contorno)

    n_ij = zeros(Int, nx, ny)
    fuera_contorno = 0

    for k in 1:N
        if xp[k] < -half_side || xp[k] >= half_side || yp[k] < -half_side || yp[k] >= half_side
            fuera_contorno += 1
            continue
        end 
        i = round(Int, (xp[k] - (-half_side))/dx)
        j = round(Int, (yp[k] - (-half_side))/dy)
        i = clamp(i, 1, nx)
        j = clamp(j, 1, ny)
        n_ij[i, j] += 1
    end

    if fuera_contorno > 0
        println("Aviso: ", fuera_contorno, " proyectiles cayeron fuera del contorno de la malla y no se contabilizaron.")
    end

    P_ij = n_ij ./ N



    return P_ij, x_contorno, y_contorno
end

function PlotImpact(
    data,
    volcan;
    output_dir = joinpath(@__DIR__, "..", "data", "output"),
)
    xp = [p.pos[end][1] for p in data]
    yp = [p.pos[end][2] for p in data]
    
    P_ij, x_contorno, y_contorno = ImpactProbability(xp, yp, 5000.0, 40, 40)
    fig = Figure(size = (1600, 1050), fontsize = 22, backgroundcolor = :white)
    Label(
        fig[0, 1],
        "Probabilidad de impacto por celda",
        fontsize = 32,
        font = :bold,
        halign = :center,
        justification = :center,
    )
    ax = Axis(
        fig[1, 1],
        xlabel = "X (m)",
        ylabel = "Y (m)",
        xticks = LinearTicks(5),
        yticks = LinearTicks(5),
        aspect = DataAspect(),
    )
    # agarrar las curvas de nivel que uso andresito para hacer un mapa en 2D
    contourf!(
        ax,
        volcan.x_coords,
        volcan.y_coords,
        volcan.z_matrix',
        levels = 24,
        colormap = :Greys,
    )
    
    
    P_plot = map(v -> v == 0.0 ? NaN : v, P_ij)
    valores_validos = filter(!isnan, vec(P_plot))
    #Revisa si esta vacio o no el set, si esta vacio lo llena con 0.05, si no son vacios se calcual el percentil.
    p95 = isempty(valores_validos) ? 0.005 : quantile(valores_validos, 0.95) 
    p90 = isempty(valores_validos) ? 0.002 : quantile(valores_validos, 0.90)
    p50 = isempty(valores_validos) ? 0.001 : quantile(valores_validos, 0.50)
    p_max =  isempty(valores_validos) ? 1 : maximum(valores_validos)
    P_discreta = map(v -> begin
        if isnan(v)
            return NaN
        elseif v<p50
            return 1.0
        elseif v < p90
            return 2.0
        elseif v < p95
            return 3.0
        else
            return 4.0
        end
    end, P_plot)

    m_color = [
            RGBAf(0.0, 1.0, 0.0, 0.5),  # Green (Under 50%)
            RGBAf(1.0, 1.0, 0.0, 0.5),  # Yellow (50% - 90%)
            RGBAf(1.0, 0.5, 0.0, 0.5),  # Orange (90% - 95%)
            RGBAf(1.0, 0.0, 0.0, 0.5)   # Red (Over 95%)
        ]

    niveles_discretos = [0.5, 1.5, 2.5, 3.5, 4.5]
    niveles_continuos = [p50, p90, p95, p_max]
    hm = contourf!(
        ax,
        x_contorno,
        y_contorno,
        P_discreta,
        colormap = m_color,
        levels = niveles_discretos,
        extendlow = :transparent
    )
    Colorbar(
        fig[1, 2], 
        hm, 
        label = "Rangos de Probabilidad por Percentil",
        ticks = ([1.0, 2.0, 3.0, 4.0], ["<50%", "50%-90%", "90%-95%", ">95%"])
    )
    colgap!(fig.layout, 1, 10)
    xlims!(ax, first(x_contorno), last(x_contorno))
    ylims!(ax, first(y_contorno), last(y_contorno))

    mkpath(output_dir)
    prob_map = joinpath(output_dir, "Probability_map.png")
    save(prob_map, fig, px_per_unit = 2)
    println("Mapa de probabilidad guardado en: ", abspath(prob_map))
    display(fig)
    return fig
end
end
