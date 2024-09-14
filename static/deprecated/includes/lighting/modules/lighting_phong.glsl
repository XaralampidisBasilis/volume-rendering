/**
 * Calculates the final color using the Phong-Blin reflection model.
 *
 * @param light: a structure holding all the lighting uniforms
 * @param color: Base color of the object
 * @param normal_vector: Normal vector at the surface point
 * @param view_vector: Vector from the surface point to the viewer
 * @param source_vector: Vector from the surface point to the light source
 * @return vec3 The final color after applying lighting
 */
vec3 lighting_phong
(
    in uniforms_lighting u_lighting, 
    in vec3 color, 
    in vec3 normal_vector, 
    in vec3 surface_position, 
    in vec3 view_position, 
    in vec3 light_position
)
{
    // calculate lighting vectors
    vec3 view_vector = view_position - surface_position;
    vec3 light_vector = light_position - surface_position;

   // Calculate attenuation frading
    float attenuation_fading = compute_attenuation(u_lighting, light_vector);

    // normalize lighting vectors
    view_vector = normalize(view_vector);
    light_vector = normalize(light_vector);
    normal_vector = normalize(normal_vector);
    // normal_vector = -faceforward(normal_vector, view_vector, normal_vector); // ensure the normal points towards the viewer

    // Calculate edge fading 
    float edge_fading = compute_edge(u_lighting, view_vector, normal_vector);

    // Calculate ambient component
    vec3 ambient_component = compute_ambient(u_lighting, color);

    // Calculate diffuse component
    float lambertian;
    vec3 diffuse_component = compute_diffuse(u_lighting, color, normal_vector, light_vector, lambertian);

    // Calculate specular component 
    float specular = 0.0;
    vec3 specular_component = vec3(0.0);

    if (lambertian > 0.0) 
        specular_component = compute_specular_phong(u_lighting, color, normal_vector, view_vector, light_vector, specular);

    // Compose the final color
    vec3 directional_component = mix(diffuse_component, specular_component, specular);
    directional_component *= 1.0 - edge_fading;
    directional_component *= attenuation_fading;

    vec3 final_color = ambient_component + directional_component;
    final_color *= u_lighting.power;

    return final_color;
}
