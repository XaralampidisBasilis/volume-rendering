#include ../lighting/lighting_phong.glsl;
#include ../lighting/lighting_phong_blin.glsl;
#include ../lighting/lighting_phong_blin_toon.glsl;
#include ../lighting/lighting_phong_blin_edge.glsl;

/**
 * Calculates the final color using the Phong or Phong-Blin reflection model.
 *
 * @param light: a structure holding all the lighting uniforms
 * @param color: Base color of the object
 * @param normal_vector: Normal vector at the surface point
 * @param view_vector: Vector from the surface point to the viewer
 * @param source_vector: Vector from the surface point to the light source
 * @return vec3 The final color after applying lighting
 */
vec3 compute_lighting(in uniforms_lighting u_lighting, in vec3 color, in vec3 normal_vector, in vec3 surface_position, in vec3 view_position, in vec3 source_position)

{
    switch (u_lighting.model)
    {
        case 1: 
            return lighting_phong(u_lighting, color, normal_vector, surface_position, view_position, source_position);
        case 2: 
            return lighting_phong_blin(u_lighting, color, normal_vector, surface_position, view_position, source_position);
        case 3: 
            return lighting_phong_blin_toon(u_lighting, color, normal_vector, surface_position, view_position, source_position);
        case 4: 
            return lighting_phong_blin_edge(u_lighting, color, normal_vector, surface_position, view_position, source_position);    
        default: 
            return vec3(1.0, 0.0, 0.0); // error color
    }
}
