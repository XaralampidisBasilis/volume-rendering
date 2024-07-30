#include "../../libraries/lygia/generative/random"
#include "./dithering_generative"
#include "./dithering_texture"

float compute_dithering
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in uniforms_sampler u_sampler, 
    in parameters_ray ray
)
{
    switch (u_raycast.dither_method)
    {
        case 1: 
            return dithering_generative(u_volume, ray);
        case 2: 
            return dithering_texture(u_volume, u_sampler.noise, ray);
        default: 
            return 0.0; 
    }
}