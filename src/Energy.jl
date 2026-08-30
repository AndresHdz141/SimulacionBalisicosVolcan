module Energy
using ..Objects
using ..Kernels
using GLMakie
using LinearAlgebra
using Statistics

export PlotEnergyFigures

function energyAnalysis!(data)
    # Calcula y guarda la energía cinética en el impacto de cada proyectil.
    for proyectil in data
        masa = proyectil.masa
        rapidez = norm(proyectil.vel[end])

        proyectil.EK = 0.5 * masa * rapidez^2
    end

    return data
end

function PlotEnergyFigures(
    data,
    volcan::VolcanoData,    
    resolucion = 500,
    output_dir = joinpath(@__DIR__, "..", "data", "output")
)
    energyAnalysis!(data)
    # Se descartan resultados sin energía o sin una posición de impacto válida.
    proyectiles = [
        proyectil for proyectil in data
        if isfinite(proyectil.EK) && proyectil.EK > 0 && !isempty(proyectil.pos)
    ]

    isempty(proyectiles) && error("No hay energías de impacto válidas para graficar.")

    #para mostrar el impacto
    x_impacto = [proyectil.pos[end][1] for proyectil in proyectiles]
    y_impacto = [proyectil.pos[end][2] for proyectil in proyectiles]

    energia_mj = [proyectil.EK / 1.0e6 for proyectil in proyectiles] #cambiar J a MJ

    x_grid = range(
        -5000, 5000;
        length = resolucion,
    )

    y_grid = range(
        -5000, 5000;
        length = resolucion,
    )
    std_x = std(x_impacto)
    std_y = std(y_impacto)
    std_data = norm(std_x, std_y)
    N = length(x_impacto)
    bandwidth = std_data * N ^ (-1/6)

    densidad_energia = gaussianKDE2D(
        x_impacto,
        y_impacto,
        energia_mj,
        x_grid,
        y_grid,
        bandwidth,
    )

    # Convertir de MJ/m² a MJ/km²
    densidad_energia .*= 1.0e6

    # Estadísticos principales
    energia_mediana = median(energia_mj)
    energia_p90 = quantile(energia_mj, 0.90)
    energia_p95 = quantile(energia_mj, 0.95)
    energia_maxima = maximum(energia_mj)
    energia_media = mean(energia_mj)

    # Esto se hace para clasificar el tipo de proyectil dependiendo de donde esta en una divicion de percentiles
    # categorias = map(energia_mj) do energia
    #     if energia <= energia_mediana
    #         1
    #     elseif energia <= energia_p90
    #         2
    #     elseif energia <= energia_p95
    #         3
    #     else
    #         4
    #     end
    # end

    # colores = [:steelblue, :gold, :darkorange, :crimson]
    # tamanos = [10, 13, 17, 22]
    # etiquetas = [
    #     "Baja (≤ mediana)",
    #     "Media (P50–P90)",
    #     "Alta (P90–P95)",
    #     "Muy alta (> P95)",
    # ]

    mkpath(output_dir)

    # mapa 2D de impactos clasificados por nivel de energía.
    fig_mapa = Figure(size = (1600, 1050), fontsize = 22, backgroundcolor = :white)
    Label(
        fig_mapa[0, 1],
        "Distribución espacial de la energía de impacto",
        fontsize = 32,
        font = :bold,
        halign = :center,
        justification = :center,
    )

    ax_mapa = Axis(
        fig_mapa[1, 1],
        xlabel = "X (m)",
        ylabel = "Y (m)",
        xticks  = LinearTicks(5),
        yticks  = LinearTicks(5),
        aspect = DataAspect(),
    )

    # agarrar las curvas de nivel que uso andresito para hacer un mapa en 2D
    contourf!(
        ax_mapa,
        volcan.x_coords,
        volcan.y_coords,
        volcan.z_matrix',
        levels = 24,
        colormap = :Greys,
    )

    #coloca los proyectiles encima del mapa
    # for categoria in 1:4
    #     indices = findall(==(categoria), categorias)
    #     scatter!(
    #         ax_mapa,
    #         x_impacto[indices],
    #         y_impacto[indices],
    #         color = colores[categoria],
    #         markersize = tamanos[categoria],
    #         strokecolor = :white,
    #         strokewidth = 0.8,
    #         label = etiquetas[categoria],
    #     )
    # end

    # Legend(
    #     fig_mapa[1, 2],
    #     ax_mapa,
    #     "Nivel relativo de energía",
    #     framevisible = false,
    # )

    umbral = 0.01 * maximum(densidad_energia)

    densidad_visible = map(densidad_energia) do valor
        valor < umbral ? NaN : valor
    end

    # Se muestra la densidad de energia encima de los relieves
    mapa_energia = contourf!(
        ax_mapa,
        x_grid,
        y_grid,
        densidad_visible,
        levels = 20,
        colormap = :inferno,
        extendlow = :transparent,
    )

    Colorbar(
        fig_mapa[1, 2],
        mapa_energia,
        label = "Densidad de energía (MJ/km²)",
    )

    xlims!(ax_mapa, -5000.0, 5000.0)
    ylims!(ax_mapa, -5000.0, 5000.0)

    colgap!(fig_mapa.layout,1,10)
    Label(
        fig_mapa[2, 1],
        "Densidad espacial de energia mediante KDE gaussiano; ancho de banda = $(bandwidth) m ",
        fontsize = 18,
        halign = :center,
    )

    # histograma y resumen estadístico
    fig_distribucion = Figure(size = (1500, 900), fontsize = 22, backgroundcolor = :white)
    Label(
        fig_distribucion[0, 1],
        "Distribución de energías de impacto",
        fontsize = 32,
        font = :bold,
        halign = :center,
        justification = :center,
    )

    ax_histograma = Axis(
        fig_distribucion[1, 1],
        xlabel = "EK de impacto (MJ)",
        ylabel = "Proporción de proyectiles",
    )

    # Se usa un número de intervalos proporcional a la raíz del total de datos.
    numero_bins = clamp(round(Int, sqrt(length(energia_mj))), 12, 60)
    hist!(
        ax_histograma,
        energia_mj,
        bins = numero_bins,
        normalization = :probability,
        color = (:darkorange, 0.85),
        strokecolor = :white,
        strokewidth = 1,
    )

    # Líneas de referencia para el centro de los datos y percentil 95 para definir donde estan las energias altas
    vlines!(
        ax_histograma,
        [energia_mediana],
        color = :dodgerblue,
        linewidth = 3,
        label = "Mediana",
    )
    vlines!(
        ax_histograma,
        [energia_p95],
        color = :crimson,
        linewidth = 3,
        label = "P95",
    )
    axislegend(ax_histograma, position = :rt, framevisible = false)

    # Resumen numérico con una explicación de P95.
    resumen = join(
        [
            "RESUMEN",
            "Proyectiles: $(length(proyectiles))",
            "Media: $(round(energia_media, sigdigits = 4)) MJ",
            "Mediana: $(round(energia_mediana, sigdigits = 4)) MJ",
            "P90: $(round(energia_p90, sigdigits = 4)) MJ",
            "P95: $(round(energia_p95, sigdigits = 4)) MJ",
            "Máxima: $(round(energia_maxima, sigdigits = 4)) MJ",
            "",
            "P95: 95 % de los impactos queda",
            "por debajo de este valor y 5 % lo supera.",
        ],
        "\n",
    )

    Label(
        fig_distribucion[1, 2],
        resumen,
        fontsize = 24,
        halign = :left,
        valign = :center,
        tellwidth = false,
        justification = :left,
    )

    mapa_path = joinpath(output_dir, "KPE_energy_map.png")
    distribucion_path = joinpath(output_dir, "impact_energy_distribution.png")
    save(mapa_path, fig_mapa, px_per_unit = 2)
    save(distribucion_path, fig_distribucion, px_per_unit = 2)
    display(fig_mapa)
    display(fig_distribucion)

    println("Mapa de impactos guardado en: ", abspath(mapa_path))
    println("Distribución de energías guardada en: ", abspath(distribucion_path))

    return (mapa = fig_mapa, distribucion = fig_distribucion)
end


end
