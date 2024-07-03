#include ../stride/isotropic.glsl;
#include ../stride/directional.glsl;
#include ../stride/traversal.glsl;

/**
 * Calculates the stride (step vector) for raycasting with 4 different methods
 * 1 isotropic 2 directional 3 traversal 4 anisotropic
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @param ray_bounds: Vector containing the start and end distances of the ray within the volume (in normalized coordinates)
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 stride(in uniforms_raycast u_raycast, in uniforms_volume u_volume, in vec3 ray_normal, in vec2 ray_bounds) 
{
    switch(u_raycast.stride)
    {
        case 1: 
            return isotropic(u_raycast, u_volume, ray_normal);
        case 2: 
            return directional(u_raycast, u_volume, ray_normal);
        case 3: 
            return traversal(u_raycast, u_volume, ray_normal, ray_bounds);
    }
}