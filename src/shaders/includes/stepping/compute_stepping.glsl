#include "./stepping_adaptive"
#include "./stepping_gradial"
#include "./stepping_alignment"
#include "./stepping_steepness"
#include "./stepping_uniform"

/**
 * Calculates the march (spacing vector) for raycasting with 4 different methods
 * 1 isotropic 2 directional 3 traversal 4 anisotropic
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The march vector for spacingping through the volume along the ray.
 */
float compute_stepping
(
    in uniforms_raycast u_raycast,
    in uniforms_gradient u_gradient,
    in parameters_ray ray,
    in parameters_trace trace
) 
{
    switch(u_raycast.stepping_method)
    {
        case 1: 
            return stepping_adaptive(u_raycast, ray, trace);
        case 2: 
            return stepping_gradial(u_raycast, u_gradient, ray, trace);
        case 3: 
            return stepping_alignment(u_raycast, ray, trace);
        case 4: 
            return stepping_steepness(u_raycast, u_gradient, ray, trace);
        case 5: 
            return stepping_uniform(u_raycast, ray, trace);
    }
}