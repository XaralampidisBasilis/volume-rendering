#include "../../libraries/lygia/generative/random"
#include "./dithering_generative"
#include "./dithering_texture"

float compute_dithering
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
            return dithering_generative(volume_size, ray_direction, ray_bounds);
        case 2: 
            return dithering_texture(noisemap, volume_size, ray_direction, ray_bounds);
        default: 
            return 0.0; 
    }
}