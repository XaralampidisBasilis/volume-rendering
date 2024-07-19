#include "../../libraries/lygia/generative/random"
#include "./dithering_generative"
#include "./dithering_texture"

float compute_dithering
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in vec3 ray_normal, 
    in vec2 ray_bounds
)
{
    switch (u_raycast.dither_method)
    {
        case 1: 
            return dithering_generative(u_raycast, u_volume, u_sampler, ray_normal, ray_bounds);
        case 2: 
            return dithering_texture(u_raycast, u_volume, u_sampler, ray_normal, ray_bounds);
        default: 
            return 0.0; 
    }
}