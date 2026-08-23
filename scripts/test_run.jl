
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
    filepath = joinpath(@__DIR__, "..", "data", "input", "volcano4_hh.tif")
    volcan = VolcanoData(path = filepath)
    #Se genera el proyectil
    entorno = Environment(
        altura_crater = 3900.0,
        radio_crater = 140.0,
        velocidad_aire = SVector{3, Float64}(0.0, 0.0, 0.0)
    )
    n_proyectiles = 1000
    max_steps = 10000

    all_projectiles_data = Vector{ProyectileData}(undef, n_proyectiles)

    for i ∈ 1:n_proyectiles
            
        roca = VolcanicProjectile(
            ca = 0.56,
            rad = rand(0.032:0.005:5.0) ,  #m
            dens = rand(2100:2500),  #kg/m^3
            posicion_ini = CraterRandomPos(entorno),     #Altura inicial del proyectil
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
        pos_history = Vector{SVector{3, Float64}}(undef, max_steps)
        vel_history = Vector{SVector{3, Float64}}(undef, max_steps)
        acc_history = Vector{SVector{3, Float64}}(undef, max_steps)
        time_history = Vector{Float64}(undef, max_steps)

        dt = 0.1
        time = 0.0

        pos_history[1] = roca.pos
        vel_history[1] = roca.vel
        acc_history[1] = roca.acc
        time_history[1] = time
        #Se itera y guardan los datos hasta que la roca toce el suelo (z=0)
        step = 1
        while step < max_steps
            pos_ant = roca.pos
            time += dt
            RK4!(roca, entorno, dt)
            if !CheckColisions(roca, volcan)
                exact_pos = BinarySearch(pos_ant, roca.pos, volcan)
                step += 1
                pos_history[step] = exact_pos
                break
            end
            step += 1
            pos_history[step] = roca.pos
            vel_history[step] = roca.vel
            acc_history[step] = roca.acc
            time_history[step] = time
        end
        resize!(pos_history, step)
        resize!(vel_history, step)
        resize!(acc_history, step)
        resize!(time_history, step)
        #join position, velocity and acceleration into a vector
        all_projectiles_data[i] = ProyectileData(i, roca.masa, pos_history, vel_history, acc_history)
        
    end
    print("Finalizado")

    PlotGraph(all_projectiles_data, volcan)

    n_ij, P_ij = GridImpactProbability3D(all_projectiles_data, volcan)
    
    println("Suma de P_ij: ", sum(P_ij))
    PlotImpactMap3D(volcan,P_ij; label= "P_ij = n_ij / N")

    readline()
    
end

run_test()