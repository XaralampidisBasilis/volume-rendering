#include "../../libraries/lygia/generative/random"
#include "./dither_generative"
#include "./dither_texture"

float compute_dither
(
    in uniforms_raycast u_raycast, 
    in sampler2D noisemap, 
    in vec3 volume_size, 
    in vec3 ray_direction,
    in vec2 ray_bounds
)
{
    switch (u_raycast.dither_method)
    {
        case 1: 
            return dither_generative(volume_size, ray_direction, ray_bounds);
        case 2: 
            return dither_texture(noisemap, volume_size, ray_direction, ray_bounds);
        default: 
            return 0.0; 
    }
}