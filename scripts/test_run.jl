
include("../src/Objects.jl")
include("../src/Physics.jl")  # Asumiendo que existe
include("../src/Solvers.jl")
include("../src/DataProcess.jl")

using .Objects
using .Physics 
using .Solvers
using .DataProcess
using StaticArrays

#Funcion para la prueba
function run_test()

#Se genera el proyectil

volcan = Environment(
    altura_base = 1800.0,
    altura_crater = 2500.0,
    latitud = 180.0,
)

roca = VolcanicProjectile(
    ca = 0.56,
    rad = 0.05 ,  #m
    dens = 2500,  #kg/m^3
    altura_ini = volcan.altura_crater  ,     #Altura inicial del proyectil
    v0 = 300.0   ,          #Magnitud de velocidad inicial del proyectil
    theta = 30.0  ,         #angulo Horizontal 0 a 360
    phi = 60.0              #angulo vertical 30 a 90

)
#Se imprimen algunas caracteristicas
println("Running...")
println("Masa:", roca.masa)
println("Posicion:", roca.pos)
println("Velocidad", roca.vel)


#Se generan vectores para guardar los datos de posicion, velocidad, aceleracion y tiempo
pos_history::Vector{SVector{3, Float64}} = [roca.pos]
vel_history::Vector{SVector{3, Float64}} = [roca.vel]
acc_history::Vector{SVector{3, Float64}} = [roca.acc]
time_history::Vector{Float64} = [0.0]

dt = 0.1
time = 0.0
while (roca.pos[3] >= 0)
time += dt
push!(time_history, time)
RK4!(roca, volcan, dt)
push!(pos_history, roca.pos)
push!(vel_history, roca.vel)
push!(acc_history, roca.acc)

end

println("Simulation Complete")
readline()
for i in 1:length(pos_history)
    print(round(time_history[i],digits = 2), "--")
    println(pos_history[i])
end
PlotGraph(pos_history)
readline()
end

run_test()