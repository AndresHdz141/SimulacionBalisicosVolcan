using Pkg
Pkg.activate(dirname(@__DIR__)) #Se activa el proyect environment para utilizar los paquetes necesarios
#Generar particulas, resolver simulacion,generar datos, guardar datos, generar graficas, exportar graficas.

print("Running simulation...")

volcan = volcan...
datos = simulate_particles(altura_inicial, )

PlotImpact(all_projectiles_data, volcan)    #Grafica el mapa de probabilidad de impacto

PlotEnergyFigures(all_projectiles_data, volcan)

