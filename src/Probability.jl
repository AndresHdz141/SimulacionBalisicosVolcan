module Probability
using ..Kernels
using GLMakie #Libreria para graficar en 3d utilizando GPU
using StaticArrays
#using Makie.Colors
using Statistics
using LinearAlgebra


export PlotImpact

function PlotImpact(
    data,
    volcan, 
    resolucion;
    output_dir = joinpath(@__DIR__, "..", "data", "output"),
)
    isempty(data) && error("No hay impactos para calcular la probabilidad.")

    xp = [p.pos[end][1] for p in data]
    yp = [p.pos[end][2] for p in data]

    std_x = std(xp)
    std_y = std(yp)
    std_data = norm(std_x, std_y)
    N = length(xp)
    bandwidth = std_data * N ^ (-1/6)
    half_side = 5000.0
   
    x_contorno = range(-half_side, half_side; length = resolucion)
    y_contorno = range(-half_side, half_side; length = resolucion)

    # Cada impacto aporta la misma fraccion de probabilidad: 1/N.
    probability_weights = fill(1.0 / length(xp), length(xp))
    densidad_probabilidad = gaussianKDE2D(
        xp,
        yp,
        probability_weights,
        x_contorno,
        y_contorno,
        bandwidth,
    )

    # Convertir de 1/m² a 1/km².
    densidad_probabilidad .*= 1.0e6

    fig = Figure(size = (1600, 1050), fontsize = 22, backgroundcolor = :white)
    Label(
        fig[0, 1],
        "Densidad espacial de probabilidad de impacto",
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
    
    
    densidad_maxima = maximum(densidad_probabilidad)
    densidad_maxima > 0 || error("La densidad de probabilidad es cero dentro del area mostrada.")
    umbral = 0.01 * densidad_maxima
    P_plot = map(v -> v < umbral ? NaN : v, densidad_probabilidad)
    valores_validos = filter(!isnan, vec(P_plot))
    p95 = quantile(valores_validos, 0.95)
    p90 = quantile(valores_validos, 0.90)
    p50 = quantile(valores_validos, 0.50)
    P_discreta = map(v -> begin
        if isnan(v)
            return NaN
        elseif v < p50
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
        label = "Densidad KDE por percentil",
        ticks = ([1.0, 2.0, 3.0, 4.0], ["<50%", "50%-90%", "90%-95%", ">95%"])
    )
    colgap!(fig.layout, 1, 10)
    xlims!(ax, first(x_contorno), last(x_contorno))
    ylims!(ax, first(y_contorno), last(y_contorno))

    Label(
        fig[2, 1],
        "KDE gaussiana de probabilidad; ancho de banda = $(bandwidth) m",
        fontsize = 18,
        halign = :center,
    )

    mkpath(output_dir)
    prob_map = joinpath(output_dir, "Probability_map.png")
    save(prob_map, fig, px_per_unit = 2)
    println("Mapa de probabilidad guardado en: ", abspath(prob_map))
    display(fig)
    return fig
end
end
