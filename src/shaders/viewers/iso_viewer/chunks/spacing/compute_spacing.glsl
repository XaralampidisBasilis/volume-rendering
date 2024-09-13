/**
 * Calculates the march (spacing vector) for raycasting with 4 different methods
 * 1 isotropic 2 directional 3 traversal 4 anisotropic
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The march vector for spacingping through the volume along the ray.
 */

#ifndef SPACING_METHOD
    #define SPACING_METHOD 2
#endif

#if SPACING_METHOD == 1  
    #include "./modules/spacing_isotropic"
   
#elif SPACING_METHOD == 2
    #include "./modules/spacing_directional"

#elif SPACING_METHOD == 3
    #include "./modules/spacing_traversal"

#else  
    #error "unknown: SPACING_METHOD"
#endif