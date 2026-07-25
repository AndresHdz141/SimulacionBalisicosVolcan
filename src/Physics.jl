module Physics
include("Objects.jl") #Incluye los data structs del archivo "Objects.jl"
using VolcanicProyectile, Environment #Se utilizan los structs VolcanicProyectile y Environment


function initial_data_producer(obj::VolcanicProyectile, env::Environment)

    #checa que las velocidades iniciales y masas sean coherentes para un proyectil usando energias
    
end




function acceleration(obj::VolcanicProyectile, env::Environment)

#=
Añadir la logica de la aceleracion para el tipo de particula VolcanicProyectile en un ambiente Environment.
=#

end

#Agregar funcion de densidad del aire respecto a la altura (Barometric formula)
function AirDensity(obj::VolcanicProyectile, env::Environment)

end

#En caso de ser posible/tiempo añadir comportamiento de solidificacion del proyectil respecto a tiempo 
#(debido a que la explosion lanza magma viscoza que se enfría y solidifica), lo que cambia el arrastre que experimenta.



end