vec3 compute_specular_blinn
(
    in uniforms_lighting u_lighting, 
    in vec3 color,
    in vec3 normal_vector, 
    in vec3 view_vector, 
    in vec3 light_vector,
    out float specular
)
{
    float shininess = u_lighting.shininess;
    vec3 halfway_vector = normalize(light_vector + view_vector); 

    specular = clamp(dot(halfway_vector, normal_vector), 0.0, 1.0);
    specular = pow(specular, shininess) * u_lighting.ks;

    return mix(color, u_lighting.s_color, specular * u_lighting.ks);
}