
include("../src/Objects.jl")
include("../src/Physics.jl")  # Asumiendo que existe
include("../src/Solvers.jl")
include("../src/DataProcess.jl")

using .Objects
using .Physics 
using .Solvers
using .DataProcess
using StaticArrays

    struct ProyectileData
        id::Int64
        pos::Vector{SVector{3, Float64}}
        vel::Vector{SVector{3, Float64}}
        acc::Vector{SVector{3, Float64}}
    end

#Funcion para la prueba
function run_test() 
    #Se genera el proyectil
    volcan = Environment(
        altura_base = 2000.0,
        altura_crater = 3900.0,
        radio_crater = 140.0,
        latitud = 180.0,
    )
    n_proyectiles = 500
    all_projectiles_data = Vector{ProyectileData}(undef, n_proyectiles)

    for i ∈ 1:n_proyectiles
            
        roca = VolcanicProjectile(
            ca = 0.56,
            rad = rand(0.032:0.005:5.0) ,  #m
            dens = rand(2100:2500),  #kg/m^3
            posicion_ini = CraterRandomPos(volcan),     #Altura inicial del proyectil
            v0 = rand(debil.Vmin:debil.Vmax),          #Magnitud de velocidad inicial del proyectil
            theta = rand(0.0:360.0)  ,         #angulo Horizontal 0 a 360
            phi = rand(30.0:90)             #angulo vertical 30 a 90
        )
           #= #Se imprimen algunas caracteristicas
            println("Running...")
            println("Masa:", roca.masa)
            println("Posicion:", roca.pos)
            println("Velocidad", roca.vel)
            =#
        #Se generan vectores para guardar los datos de posicion, velocidad, aceleracion y tiempo
        pos_history::Vector{SVector{3, Float64}} = [roca.pos]
        vel_history::Vector{SVector{3, Float64}} = [roca.vel]
        acc_history::Vector{SVector{3, Float64}} = [roca.acc]
        time_history::Vector{Float64} = [0.0]

        dt = 0.1
        time = 0.0
        #Se itera y guardan los datos hasta que la roca toce el suelo (z=0)
        while (roca.pos[3] >= volcan.altura_base)
            time += dt
            push!(time_history, time)
            RK4!(roca, volcan, dt)
            push!(pos_history, roca.pos)
            push!(vel_history, roca.vel)
            push!(acc_history, roca.acc)
        end
        #join position, velocity and acceleration into a vector
        all_projectiles_data[i] = ProyectileData(i, pos_history, vel_history, acc_history)
        println("Proyectil ", i)
    end
    print("Finalizado")

    PlotGraph(all_projectiles_data)

    xp = [p.pos[end][1] for p in all_projectiles_data]
    yp = [p.pos[end][2] for p in all_projectiles_data]

    n_ij, P_ij, x_contorno, y_contorno = ImpactProbability(xp, yp, -5000.0, 5000.0, -5000.0, 5000.0, 40, 40)

    PlotImpact(P_ij, x_contorno, y_contorno)

    readline()
    
end

run_test()