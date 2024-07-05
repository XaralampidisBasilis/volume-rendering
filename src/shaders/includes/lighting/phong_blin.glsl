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
vec3 phong_blin(in uniforms_lighting u_lighting, in vec3 color, in vec3 normal_vector, in vec3 surface_position, in vec3 view_position, in vec3 source_position)
{
    // calculate lighting vectors
    vec3 view_vector = surface_position - view_position;
    vec3 source_vector = surface_position - source_position;

    // Calculate distance and its squared value, considering attenuation
    float distance_inv = 1.0 / (length(source_vector) + length(view_vector));
    float attenuation = mix(1.0, distance_inv * distance_inv, u_lighting.attenuate) * u_lighting.power;  
    
    // Normalize lighting vectors
    view_vector = normalize(view_vector);
    source_vector = normalize(source_vector);

    // Compute ambient, diffuse, and specular color components
    vec3 a_color = u_lighting.a_color * u_lighting.ka;
    vec3 d_color = u_lighting.d_color * u_lighting.kd * attenuation;
    vec3 s_color = u_lighting.s_color * u_lighting.ks * attenuation;

    // Ensure the normal points towards the viewer
    normal_vector = -faceforward(normal_vector, view_vector, normal_vector);

    // Calculate lambertian (diffuse) component
    float lambertian = max(dot(normal_vector, source_vector), 0.0);

    // Calculate specular component if lambertian contribution is positive
    float specular = 0.0;
    float specular_angle;
    
    if (lambertian > 0.0) 
    {
        vec3 halfway_vector = normalize(source_vector + view_vector); 
        specular_angle = max(dot(halfway_vector, normal_vector), 0.0);
        specular = pow(specular_angle, u_lighting.shininess);
    }    

    // Calculate the final color by combining ambient, diffuse, and specular components
    vec3 phong_blin_color = a_color + color * (lambertian * d_color + specular * s_color);

    return phong_blin_color;
}
