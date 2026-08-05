module Solvers
include("Physics.jl") #Incluye las funciones del archivo "Physics.jl"

#Metodo RK4 
# obj (sistema a resolver) - velocidad, posicion, masa, etc. \ Struct
# env (universo interactuando con el sistema / ambiente) - densidad del aire, velocidad del viento, temp, etc. \ Struct
# dt - paso del tiempo para resolver \ Float64
function RK4!(obj::Any, env::Any, dt::Float64) 
    pos0 = copu(obj.vel)
    vel0 = copy(obj.vel)
   
    
    
    #=
    Añadir el resto de la logica para un solver RK4 general en 2 o 3 dimensinoes (investigar lo mas optimo)
    =#

    

end


end
