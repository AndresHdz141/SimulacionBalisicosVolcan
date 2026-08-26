module Solvers
using ..Physics
using StaticArrays
export RK4!, CraterRandomPos, IsInsideVolcanoGrid, CheckColisions, BinarySearch
#Metodo RK4 
# obj (sistema a resolver) - velocidad, posicion, masa, etc. \ Struct
# env (universo interactuando con el sistema / ambiente) - densidad del aire, velocidad del viento, temp, etc. \ Struct
# dt - paso del tiempo para resolver \ Float64
function RK4!(obj::Any, env::Any, dt::Float64) 
    pos0 = obj.pos
    vel0 = obj.vel
    #k1
    k1x = copy(obj.vel)
    k1v = aceleracion(obj, env, pos0, vel0)
    #k2
    k2x = obj.vel + 1/2 * k1x * dt
    k2v = aceleracion(obj, env, pos0 + dt/2 * k1x, vel0 + dt/2 * k1v)
    #k3
    k3x = obj.vel + 1/2 * k2x * dt
    k3v = aceleracion(obj, env, pos0 + dt/2 * k2x, vel0 + dt/2 * k2v)
    #k4
    k4x = obj.vel + k3x * dt
    k4v = aceleracion(obj, env, pos0 + k3x * dt, vel0 + k3v * dt)
    #Update
    obj.vel = obj.vel + dt/6 * (k1v + 2*k2v + 2k3v + k4v)
    obj.pos = obj.pos + dt/6 * (k1x + 2*k2x + 2k3x + k4x)
    obj.acc = aceleracion(obj,env, obj.pos, obj.vel)
end

function CraterRandomPos(env::Any)
    x = rand(-env.radio_crater:0.1:env.radio_crater)
    y = rand(-env.radio_crater:0.1:env.radio_crater)
    return SVector{3, Float64}(x, y, env.altura_crater)

end

function IsInsideVolcanoGrid(particle::Any, VolcanoGrid::Any)
    x, y, _ = particle.pos
    return first(VolcanoGrid.x_coords) <= x <= last(VolcanoGrid.x_coords) &&
           first(VolcanoGrid.y_coords) <= y <= last(VolcanoGrid.y_coords)
end

function CheckColisions(particle::Any, VolcanoGrid::Any)

    grid_z = VolcanoGrid.z_matrix
    x,y,z = particle.pos
    inv_pixel_size = 1/VolcanoGrid.pixel_size

    x_ref = (VolcanoGrid.x_coords[1])
    y_ref = (VolcanoGrid.y_coords[1])

    IsInsideVolcanoGrid(particle, VolcanoGrid) || return true

    x_shift = (x-x_ref) * inv_pixel_size + 1
    y_shift = (y-y_ref) * inv_pixel_size + 1

    i = clamp(floor(Int, x_shift), 1, size(grid_z, 2) - 1)
    j = clamp(floor(Int, y_shift), 1, size(grid_z, 1) - 1)

    dx = x_shift - i
    dy = y_shift - j

    z00 = grid_z[j,   i]
    z10 = grid_z[j,   i+1]
    z01 = grid_z[j+1, i]
    z11 = grid_z[j+1, i+1]
    interpolated_z = (1.0 - dx) * (1.0 - dy) * z00 +
                    dx         * (1.0 - dy) * z10 +
                    (1.0 - dx) * dy         * z01 +
                    dx         * dy         * z11

    #x_shift = trunc(Int, x_shift)
    #y_shift = trunc(Int, y_shift)
    #z_mesh = VolcanoGrid.z_matrix[y_shift, x_shift]
    return (z > interpolated_z )

end

function BinarySearch(p_prev, p_next, volcan, it = 100)
    for _ in 1:it
    p_mid = p_prev + 0.5 * (p_next - p_prev)
        if CheckColisions((pos = p_mid,), volcan)
            p_prev = p_mid
        else
            p_next = p_mid
        end
    end
    return 0.5 * (p_prev + p_next)

end

end
