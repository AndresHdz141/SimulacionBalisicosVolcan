module Objects
using Random
export Eruption, debil, media, fuerte,  VolcanicProjectile, Environment

#tipo de erupcion
struct Eruption

    escenario::String

    Vmin::Float64 #m/s

    Vmax::Float64  #m/s

    max_KE::Float64 #J

    Cantidad_pr::Int

end

#erupciones-------

const debil = Eruption("debil", 110, 150, 1.3e6, 1000)

const media = Eruption("media", 120, 160, 1.0e7, 1000)

const fuerte = Eruption("fuerte", 180, 230, 8.9e7,1000)
#----

#Caracteristicas del proyectil - posicion, velocidad en x,y,z | 
Base.@kwdef mutable struct VolcanicProjectile 

    #Añadir las caracteristicas y variables necesarias para el comportamiento del proyectil
    ca::Float64

    rad::Float64
    dens::Float64
    masa::Float64
    area::Float64

    speed::Float64
    theta::Float64             #angulo Horizontal 0 a 360
    phi::Float64                #angulo vertical 30 a 80

    pos::Vector{Float64}
    vel::Vector{Float64}


end



Base.@kwdef struct Environment #Caracteristicas del ambiente
    #Añadir caracteristicas importantes
    height::Float64 = 3218.0
    height_volcano::Float64 = 5426.0
    latitud::Float64 = 19

    temp_cima::Float64 = -2
    temp_int::Float64 = 950
    humid::Float64 = 68  #%

    g::Float64 = 9.81

    L::Float64 = 0.0065  # K/m
    M::Float64 = 0.0289644  # kg/mol
    R::Float64 = 8.3144598  # J/(mol K)
    T0::Float64 = 288.15  # K
    P0::Float64 = 101325  # Pa

    #wind

    wind_ref_sp::Float64 = 0.0     #m/s
    wind_direct::Float64 = 0.0     #grados
    roughness_len::Float64 = 0.2    # m


end





end