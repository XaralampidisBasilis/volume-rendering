#include ../lighting/phong.glsl;
#include ../lighting/phong_blin.glsl;

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
vec3 lighting(in lighting_uniforms u_lighting, in vec3 color, in vec3 normal_vector, in vec3 view_vector, in vec3 source_vector)
{
    switch (u_lighting.mode)
    {
        case 1: return phong(u_lighting, color, normal_vector, view_vector, source_vector);
        case 2: return phong_blin(u_lighting, color, normal_vector, view_vector, source_vector);
        default: return vec3(1.0, 0.0, 0.0); // error color
    }
}
