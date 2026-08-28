module DataProcess
using ..Objects
using GLMakie

export PlotGraph

function PlotGraph(data, volcan::VolcanoData)
    fig = Figure()
    ax = Axis3(
        fig[1, 1],
        title = "Trayectorias de proyectiles 3D",
        xlabel = "X (m)",
        ylabel = "Y (m)",
        zlabel = "Z (m)",
    )
    valid_heights = filter(z -> !isnan(z) && z > -100.0, volcan.z_matrix)
    min_elevation = minimum(valid_heights)
    zlims!(ax, min_elevation,size(volcan.z_matrix, 1) * 15)

    for proyectil in data
        scatter!(ax, proyectil.pos, color = :black, alpha = 0.5, markersize = 0.5)
    end

    surface!(ax, volcan.x_coords, volcan.y_coords, volcan.z_matrix', colormap = :terrain)
    display(fig)

    return fig
end

end
