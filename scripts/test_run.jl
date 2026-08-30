
include("../src/Objects.jl")
include("../src/Physics.jl")
include("../src/Solvers.jl")
include("../src/DataProcess.jl")
include("../src/Kernels.jl")
include("../src/Probability.jl")
include("../src/Energy.jl")

using .Objects
using .Physics
using .Solvers
using .DataProcess
using .Kernels
using .Probability
using .Energy
using StaticArrays


#Funcion para la prueba
function run_test() 
    #Se genera la informacion del volcan
        filepath = joinpath(@__DIR__, "..", "data", "input", "volcano_20km.tif")
        volcan = VolcanoData(
            path = filepath, 
            altura_crater = 5260.0,
            radio_crater = 300.0
            )

    #Se genera la informacion del entorno
    entorno = Environment(
        velocidad_aire = SVector{3, Float64}(0.0,0.0,0.0)   #m/s
    )

    #Se especifican el numero de proyectiles y pasos maximos por dar
    n_proyectiles = 10000
    max_steps = 10000
    #Se genera el vector para guardar la informacion de los proyectiles
    all_projectiles_data = Vector{ProyectileData}(undef, n_proyectiles)

    for i ∈ 1:n_proyectiles
        #Se genera un proyectil con Caracteristicas, posicion y velocidad.
        roca = VolcanicProjectile(
            ca = 0.56,  
            rad = rand(0.032:0.005:2.5) ,               #m --> Realizar distribucion de probabilidades para los radios posibles (investigar)
            dens = rand(2100:2500),                     #kg/m^3 --> Distribucion estadistica
            posicion_ini = CraterRandomPos(volcan),     #Altura inicial del proyectil              >>>
            v0 = rand(100.0:150.0),          #Magnitud de velocidad inicial del proyectil >>>
            theta =rand(0.0:360.0),         #angulo Horizontal 0 a 360 -
            phi = rand(25.0:85.0)             #angulo vertical 30 a 90 -
        )

        #Se generan vectores para guardar los datos de posicion, velocidad, aceleracion y tiempo
        pos_history = Vector{SVector{3, Float64}}(undef, max_steps)
        vel_history = Vector{SVector{3, Float64}}(undef, max_steps)
        acc_history = Vector{SVector{3, Float64}}(undef, max_steps)

        #Tamaño de paso de tiempo y tiempo
        dt = 0.1
        time = 0.0

        #Condiciones iniciales de vectores:
        pos_history[1] = roca.pos
        vel_history[1] = roca.vel
        acc_history[1] = roca.acc
        #Se itera y guardan los datos hasta que la roca toce el suelo (topologia con interpolacion entre puntos)
        step = 1
        while (step < max_steps)
            pos_ant = roca.pos 

            time += dt
            RK4!(roca, entorno, dt)

            if !CheckColisions(roca, volcan)
                exact_pos = BinarySearch(pos_ant, roca.pos, volcan) #Encontrar el punto medio
                step += 1
                pos_history[step] = exact_pos
                vel_history[step] = roca.vel
                acc_history[step] = roca.acc
                break # Salir del loop
            end
            step+=1

            pos_history[step] = roca.pos    
            vel_history[step] = roca.vel
            acc_history[step] = roca.acc
        end
        #Ajustar el tamaño de los vectores (Recorta los elementos despues de *STEP*)
        resize!(pos_history, step)
        resize!(vel_history, step)
        resize!(acc_history, step)
        #join position, velocity and acceleration into a vector
        all_projectiles_data[i] = ProyectileData(i, roca.masa, pos_history, vel_history, acc_history, NaN)

        println("[",i,"]_Simulando...")
    end
    println("Simulación finalizada")
    #PlotGraph(all_projectiles_data, volcan)     #Simula el volcan y trayectorias en 3D
    #readline()
    println("Generando graficas...")
    PlotImpact(all_projectiles_data, volcan)    #Grafica el mapa de probabilidad de impacto
    println("Mapa de probabilidad de riesgo finalizado")
    PlotEnergyFigures(all_projectiles_data, volcan)
    println("Mapa de energias finalizado")

    readline()
    
end
run_test()

