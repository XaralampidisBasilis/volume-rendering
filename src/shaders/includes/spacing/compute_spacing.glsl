#include ./spacing_isotropic;
#include ./spacing_directional;
#include ./spacing_traversal;

/**
 * Calculates the march (spacing vector) for raycasting with 4 different methods
 * 1 isotropic 2 directional 3 traversal 4 anisotropic
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The march vector for spacingping through the volume along the ray.
 */
float compute_spacing
(
    in uniforms_raycast u_raycast, 
    in vec3 volume_dimensions, 
    in float ray_span
) 
{
    switch(u_raycast.step_method)
    {
        case 1: 
            return spacing_isotropic(volume_dimensions);
        case 2: 
            return spacing_directional(volume_dimensions);
        case 3: 
            return spacing_traversal(volume_dimensions, ray_span);
    }
}