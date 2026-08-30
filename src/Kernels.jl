module Kernels

export gaussianKDE2D

function gaussianKDE2D(x, y, pesos, x_grid, y_grid, bandwidth)
    densidad = zeros(Float64, length(x_grid), length(y_grid))
    factor = 1.0 / (2pi * bandwidth^2)

    for i in eachindex(x, y, pesos)
        kernel_x = exp.(-0.5 .* ((x_grid .- x[i]) ./ bandwidth).^2)
        kernel_y = exp.(-0.5 .* ((y_grid .- y[i]) ./ bandwidth).^2)

        densidad .+= pesos[i] * factor .* (kernel_x * transpose(kernel_y))
    end

    return densidad
end

end
