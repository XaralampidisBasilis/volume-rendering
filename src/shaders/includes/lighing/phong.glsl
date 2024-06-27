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
vec3 phong(lighting_uniforms u_lighting, vec3 color, vec3 normal_vector, vec3 view_vector, vec3 source_vector)
{
    // Calculate distance and its squared value, considering attenuation
    float distance_inv = 1.0 / length(source_vector);
    float attenuation = mix(1.0, distance_inv * distance_inv, u_lighting.attenuate) * u_lighting.power;  
    
    // Compute ambient, diffuse, and specular color components
    vec3 a_color = u_lighting.a_color * u_lighting.ka;
    vec3 d_color = u_lighting.d_color * u_lighting.kd * attenuation;
    vec3 s_color = u_lighting.s_color * u_lighting.ks * attenuation;

    // Normalize vectors
    normal_vector = normalize(normal_vector); 
    view_vector = normalize(view_vector);
    source_vector = normalize(source_vector);

    // Ensure the normal points towards the viewer
    normal_vector = -faceforward(normal_vector, view_vector, normal_vector);

    // Calculate lambertian (diffuse) component
    float lambertian = max(dot(normal_vector, source_vector), 0.0);
    float specular = 0.0;
    float specular_angle;

    // Calculate specular component if lambertian contribution is positive
    if (lambertian > 0.0) 
    {
        vec3 reflect_dir = reflect(-source_vector, normal_vector);
        specular_angle = max(dot(reflect_dir, view_vector), 0.0);
        specular = pow(specular_angle, u_lighting.shininess * 0.25);
    }    

    // Calculate the final color by combining ambient, diffuse, and specular components
    vec3 phong_color = a_color + color * (lambertian * d_color + specular * s_color);

    return phong_color;
}
