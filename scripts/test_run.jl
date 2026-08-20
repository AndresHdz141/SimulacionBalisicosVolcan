
include("../src/Objects.jl")
include("../src/Physics.jl")  
include("../src/Solvers.jl")
include("../src/DataProcess.jl")

using .Objects
using .Physics 
using .Solvers
using .DataProcess
using StaticArrays


#Funcion para la prueba
function run_test() 
    #Se genera la informacion del volcan
        filepath = joinpath(@__DIR__, "..", "data", "input", "volcano4_hh.tif")
        volcan = VolcanoData(path = filepath)

    #Se genera la informacion del 
    entorno = Environment(
        altura_base = 2400.0,
        altura_crater = 5160.0,
        radio_crater = 300.0,
        latitud = 180.0,
        velocidad_aire = SVector{3, Float64}(1.0,0.0,0.0)   #m/s
    )

    #Se especifican el numero de proyectiles y pasos maximos por dar
    n_proyectiles = 20
    max_steps = 10000
    #Se genera el vector para guardar la informacion de los proyectiles
    all_projectiles_data = Vector{ProyectileData}(undef, n_proyectiles)

    for i ∈ 1:n_proyectiles
        #Se genera un proyectil con Caracteristicas, posicion y velocidad.


        roca = VolcanicProjectile(
            ca = 0.56,
            rad = rand(0.032:0.005:5.0) ,  #m
            dens = rand(2100:2500),  #kg/m^3
            posicion_ini = CraterRandomPos(entorno),     #Altura inicial del proyectil
            v0 = rand(debil.Vmin:debil.Vmax),          #Magnitud de velocidad inicial del proyectil
            theta =rand(0.0:360.0),         #angulo Horizontal 0 a 360
            phi = rand(0.0:180)             #angulo vertical 30 a 90
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
        while ((roca.pos[3] >= entorno.altura_base) && (step < max_steps))
            time += dt
            RK4!(roca, entorno, dt)
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
    PlotGraph(all_projectiles_data, volcan)
    readline()
end
run_test()

