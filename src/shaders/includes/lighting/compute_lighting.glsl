#include ./modules/compute_edge.glsl;
#include ./modules/compute_attenuation.glsl;
#include ./modules/compute_ambient.glsl;
#include ./modules/compute_diffuse.glsl;
#include ./modules/compute_specular_phong.glsl;
#include ./modules/compute_specular_blinn.glsl;

#include ./lighting_phong.glsl;
#include ./lighting_blinn.glsl;
#include ./lighting_toon.glsl;

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
vec3 compute_lighting
(
    in uniforms_lighting u_lighting, 
    in vec3 color, 
    in vec3 normal_vector, 
    in vec3 surface_position, 
    in vec3 view_position, 
    in vec3 light_position
)
{
    switch (u_lighting.model)
    {
        case 1: 
            return lighting_phong(u_lighting, color, normal_vector, surface_position, view_position, light_position);
        case 2: 
            return lighting_blinn(u_lighting, color, normal_vector, surface_position, view_position, light_position);
        case 3: 
            return lighting_toon(u_lighting, color, normal_vector, surface_position, view_position, light_position);
        default: 
            return vec3(1.0, 0.0, 0.0); // error color
    }
}
