#include "../../libraries/lygia/generative/random"
#include "./dithering_generative"
#include "./dithering_texture"

float compute_dithering
(
    in int dithering_method, 
    in sampler2D noisemap, 
    inout parameters_ray ray
)
{
    switch (dithering_method)
    {
        case 1: 
            return dithering_generative(ray.direction, ray.origin, ray.bounds);
        case 2: 
            return dithering_texture(noisemap, ray.direction, ray.origin, ray.bounds);
        default: 
            return 0.0; 
    }
}