#include ../lighting/uniforms.glsl;

/**
 * Calculates the final color using the Phong-Blin reflection model.
 *
 * @param color: Base color of the object
 * @param N: Normal vector at the surface point
 * @param V: Vector from the surface point to the viewer
 * @param L: Vector from the surface point to the light source
 * @return vec3 The final color after applying lighting
 */
vec3 phong_blin(vec3 color, vec3 normal_vector, vec3 view_vector, vec3 light_vector)
{
    // Calculate distance and its squared value, considering attenuation
    float distance_inv = 1.0 / length(light_vector);
    float attenuation = mix(1.0, distance_inv * distance_inv, u_lighting_attenuation) * u_lighting_power;  
    
    // Compute ambient, diffuse, and specular color components
    vec3 a_color = u_lighting_a_color * u_lighting_ka;
    vec3 d_color = u_lighting_d_color * u_lighting_kd * attenuation;
    vec3 s_color = u_lighting_s_color * u_lighting_ks * attenuation;

    // Normalize vectors
    normal_vector = normalize(normal_vector); 
    view_vector = normalize(view_vector);
    light_vector = normalize(light_vector);

    // Ensure the normal points towards the viewer
    normal_vector = -faceforward(normal_vector, view_vector, normal_vector);

    // Calculate lambertian (diffuse) component
    float lambertian = max(dot(normal_vector, light_vector), 0.0);
    float specular = 0.0;
    float specular_angle;

    // Calculate specular component if lambertian contribution is positive
    if (lambertian > 0.0) 
    {
        vec3 H = normalize(light_vector + view_vector); // Halfway vector
        specular_angle = max(dot(H, normal_vector), 0.0);
        specular = pow(specular_angle, u_lighting_shininess);
    }    

    // Calculate the final color by combining ambient, diffuse, and specular components
    vec3 final_color = a_color + color * (lambertian * d_color + specular * s_color);

    return final_color;
}