module Physics
using StaticArrays
using LinearAlgebra
using ..Objects

export aceleracion


function initial_data_producer(obj::VolcanicProjectile, env::Environment)

    #checa que las velocidades iniciales y masas sean coherentes para un proyectil usando energias
    
end



#Vector
function aceleracion(obj::VolcanicProjectile, env::Environment, position::SVector{3, Float64},  velocity::SVector{3, Float64})
F_g = ForceGravity(obj, env)
F_d = ForceDrag(obj, env, position, velocity)
F_total = F_g + F_d
return F_total/obj.masa
end

#Agregar funcion de densidad del aire respecto a la altura (Barometric formula)
#Escalar
function DensidadAire(env::Environment, position::SVector{3, Float64})
return env.rho0 * exp((-env.M * norm(env.g) * position[3])/(env.R * env.T0))
end

#FUERZAS----------------

#Vector
function ForceGravity(obj::VolcanicProjectile, env::Environment)
    return obj.masa .* env.g
end

#Vector
function ForceDrag(obj::VolcanicProjectile, env::Environment, position::SVector{3, Float64}, velocity::SVector{3, Float64})
    rho = DensidadAire(env, position)
    return  -(1/2) * rho * obj.area * norm(velocity) * obj.ca * velocity
end


end