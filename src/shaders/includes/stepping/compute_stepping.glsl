#include ./step_isotropic;
#include ./step_directional;
#include ./step_traversal;

/**
 * Calculates the march (step vector) for raycasting with 4 different methods
 * 1 isotropic 2 directional 3 traversal 4 anisotropic
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The march vector for stepping through the volume along the ray.
 */
vec3 compute_stepping
(
    in uniforms_raycast u_raycast, 
    in uniforms_volume u_volume, 
    in parameters_ray ray
) 
{
    switch(u_raycast.step_method)
    {
        case 1: 
            return step_isotropic(u_volume, ray);
        case 2: 
            return step_directional(u_volume, ray);
        case 3: 
            return step_traversal(u_volume, ray);
    }
}