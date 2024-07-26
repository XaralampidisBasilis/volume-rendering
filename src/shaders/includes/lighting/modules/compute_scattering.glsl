/**
 * Computes the scattering component of the lighting model.
 *
 * @param u_lighting: a structure holding all the lighting uniforms
 * @param color: Base color of the object
 * @param normal_vector: Normal vector at the surface point
 * @param light_vector: Vector from the surface point to the light source
 * @param view_vector: Vector from the surface point to the viewer
 * @return vec3 The scattering component of the lighting
 */
vec3 compute_scattering
(
    in uniforms_lighting u_lighting, 
    in vec3 color, 
    in vec3 normal_vector, 
    in vec3 view_vector
)
{
    // Simple scattering model (you can enhance this as needed)
    float scattering = max(dot(normal_vector, view_vector), 0.0);
    return color * scattering;
}