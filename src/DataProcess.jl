module DataProcess
#Generar graficas y procesar datos (funciones)
using GLMakie
using StaticArrays
GLMakie.activate!(title = "Simulacion Balísticos", fxaa = false)

export PlotGraph

function PlotGraph(data)
fig, ax, plt = scatter(data, axis = (type = Axis3, title = "3D Proyectile Trayectory"))
display(fig)
end




end