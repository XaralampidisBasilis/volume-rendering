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
    int spacing_method, 
    in uniforms_volume u_volume, 
    inout parameters_ray ray
) 
{
    switch(spacing_method)
    {
        case 1: 
            return spacing_isotropic(u_volume.spacing);
        case 2: 
            return spacing_directional(u_volume.spacing, ray.direction);
        case 3: 
            return spacing_traversal(u_volume.spacing, u_volume.dimensions, ray.span);
    }
}