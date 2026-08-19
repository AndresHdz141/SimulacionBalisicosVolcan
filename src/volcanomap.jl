module volcanomap
export draw_volcano
using GLMakie
using DelimitedFiles
using TiffImages

function draw_volcano(ax)
file_path = joinpath(@__DIR__, "..", "data", "input", "volcano4_hh.tif")
img = TiffImages.load(file_path)
#
z_matrix = Float32.(img)
# 3. Crear figura 3D
rows, cols = size(z_matrix)
println(rows)
println(cols)
#Conversion a metros
pixel_size = 30
x_coords = -(cols/2) * pixel_size:pixel_size:(cols/2)* pixel_size -1
y_coords = -(rows/2) * pixel_size:pixel_size:(rows/2) * pixel_size -1
println(typeof(z_matrix))
println(typeof(x_coords))
println(typeof(y_coords))
#Recorte de datos
#Eje 3D
# 4. Plot the surface
# Using a topographic colormap helps visualize terrain features
surface!(ax,x_coords, y_coords, z_matrix', colormap = :terrain)
println("X_SIZE> ",size(x_coords))
println("Y_SIZE> ",size(y_coords))

end
end