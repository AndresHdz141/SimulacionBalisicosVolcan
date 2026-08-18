
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
    start_time = time()
    #Se genera el proyectil
    volcan = Environment(
        altura_base = 2000.0,
        altura_crater = 3900.0,
        radio_crater = 140.0,
        latitud = 180.0,
    )
    n_proyectiles = 1000
    max_steps = 10000
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
        #Se generan vectores para guardar los datos de posicion, velocidad, aceleracion y tiempo
        pos_history = Vector{SVector{3, Float64}}(undef, max_steps)
        vel_history = Vector{SVector{3, Float64}}(undef, max_steps)
        acc_history = Vector{SVector{3, Float64}}(undef, max_steps)
        time_history = Vector{Float64}(undef, max_steps)
        dt = 0.1
        time = 0.0
        #Condiciones iniciales de vectores:
        pos_history[1] = roca.pos
        vel_history[1] = roca.vel
        acc_history[1] = roca.acc
        time_history[1] = time
        #Se itera y guardan los datos hasta que la roca toce el suelo (z=0)
        step = 1
        while ((roca.pos[3] >= volcan.altura_base) && (step < max_steps))
            time += dt
            RK4!(roca, volcan, dt)
            step+=1
            pos_history[step] = roca.pos
            vel_history[step] = roca.vel
            acc_history[step] = roca.acc
            time_history[step] = time
        end
        #Ajustar el tamaño de los vectores (Recorta los elementos despues de *STEP*)
        resize!(pos_history, step)
        resize!(vel_history, step)
        resize!(acc_history, step)
        resize!(time_history, step)
        #join position, velocity and acceleration into a vector
        all_projectiles_data[i] = ProyectileData(i,roca.masa, pos_history, vel_history, acc_history)

    end
    elapsed_time = time() - start_time
    println("Simulation completed in: ", elapsed_time, " seconds")
    PlotGraph(all_projectiles_data)
    readline()
end
run_test()

