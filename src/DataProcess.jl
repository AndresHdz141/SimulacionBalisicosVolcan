module DataProcess
using ..Objects
using GLMakie

export PlotGraph

function PlotGraph(data, volcan::VolcanoData)
    fig = Figure(size = (1920, 1080))
    ax = Axis3(
        fig[1, 1],
        title = "Trayectorias de proyectiles 3D",
        xlabel = "X (km)",
        ylabel = "Y (km)",
        zlabel = "Z (m)",
        azimuth = 0.6 * π,
        elevation = 0.12 * π
    )
    
    valid_heights = filter(z -> !isnan(z) && z > -100.0, volcan.z_matrix)
    min_elevation = minimum(valid_heights)
    zlims!(ax, min_elevation,size(volcan.z_matrix, 1) * 15)

    for proyectil in data
        scatter!(ax, proyectil.pos, color = :black, alpha = 0.5, markersize = 0.5)
    end

    surface!(ax, volcan.x_coords, volcan.y_coords, volcan.z_matrix', colormap = :terrain, shading = true)
    save("volcan_modelo.jpg", fig)

    return fig
end

end
