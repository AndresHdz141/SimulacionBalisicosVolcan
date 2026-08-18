module Objects
using StaticArrays
export Eruption, debil, media, fuerte,  VolcanicProjectile,ProyectileData, Environment

#tipo de erupcion
struct Eruption

    escenario::String

    Vmin::Float64 #m/s

    Vmax::Float64  #m/s

    max_KE::Float64 #J

    Cantidad_pr::Int #n proyectiles

end

#erupciones-------

const debil = Eruption("debil", 110.0, 150.0, 1.3e6, 1000)

const media = Eruption("media", 120.0, 160.0, 1.0e7, 1000)

const fuerte = Eruption("fuerte", 180.0, 230.0, 8.9e7, 1000)

#----

#Caracteristicas del proyectil - posicion, velocidad en x,y,z | 
Base.@kwdef mutable struct VolcanicProjectile 

    #Añadir las caracteristicas y variables necesarias para el comportamiento del proyectil
    ca::Float64     
    rad::Float64        #m
    dens::Float64       #kg/m^3
    posicion_ini::SVector{3, Float64}    #Altura inicial del proyectil
    v0::Float64         #Magnitud de velocidad inicial del proyectil
    theta::Float64      #angulo Horizontal 0 a 360
    phi::Float64        #angulo vertical 30 a 90

    masa::Float64 = (4/3) * π * rad ^ 3 * dens      #kg
    area::Float64 = π * rad ^ 2                     #m^2

    #Para optimizar se usa SVector que crea un vector con 3 espacios.
    pos::SVector{3, Float64} = posicion_ini                          #m
    vel::SVector{3, Float64} = SVector{3, Float64}(
        v0 * cosd(phi) * cosd(theta),
        v0 * cosd(phi) * sind(theta), 
        v0 * sind(phi))                                           #m/s
    acc::SVector{3, Float64} = SVector{3, Float64}(0.0,0.0,0.0)   #m/s^2

end

struct ProyectileData
    id::Int64
    masa::Float64
    pos::Vector{SVector{3, Float64}}
    vel::Vector{SVector{3, Float64}}
    acc::Vector{SVector{3, Float64}}
end

Base.@kwdef struct Environment #Caracteristicas del ambiente 
    #Añadir caracteristicas importantes - msnm = metros sobre nivel del mar
    
    altura_base::Float64       #msnm
    altura_crater::Float64     #msnm
    radio_crater::Float64      #m 
    latitud::Float64           #°

    temp_cima::Float64 = -2    #°C
    temp_int::Float64 = 950    #°C
    humedad_rel::Float64 = 68  #%

    g::SVector{3, Float64} = SVector{3, Float64}(0.0, 0.0, -9.81) #m/s^2

    L::Float64 = 0.0065        # K/m
    M::Float64 = 0.0289644     # kg/mol
    R::Float64 = 8.3144598     # J/(mol K)
    T0::Float64 = 288.15       # K
    rho0::Float64 = 1.225       #kg/m^3

    #wind - se considera constante porque no podemos asumir un gradiente sin datos

    wind_ref_sp::Float64 = 0.0     #m/s
    wind_direct::Float64 = 0.0     #grados

end





end