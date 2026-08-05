module Physics
include("Objects.jl") #Incluye los data structs del archivo "Objects.jl"
using VolcanicProjectile, Environment #Se utilizan los structs VolcanicProyectile y Environment


function initial_data_producer(obj::VolcanicProjectile, env::Environment)

    #checa que las velocidades iniciales y masas sean coherentes para un proyectil usando energias
    
end




function aceleracion(obj::VolcanicProjectile, env::Environment, velocity::SVector)

#=
Añadir la logica de la aceleracion para el tipo de particula VolcanicProyectile en un ambiente Environment.
=#

end

#Agregar funcion de densidad del aire respecto a la altura (Barometric formula)
function DensidadAire(obj::VolcanicProjectile, env::Environment)
return env.rho0 * exp((-env.M * norm(env.g) * obj.pos[3])/(env.R * env.T0))
end

#FUERZAS----------------

function ForceGravity(obj::VolcanicProjectile, env::Environment)
    return obj.mass .* env.g
end

function ForceDrag(obj::VolcanicProjectile, env::Environment)
    rho = DensidadAire(obj, env)
    return (1/(2*obj.masa)) * rho * obj.area * norm(obj.v) ^ 2 * obj.ca

end