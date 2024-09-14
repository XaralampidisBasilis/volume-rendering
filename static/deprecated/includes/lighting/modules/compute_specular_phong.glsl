vec3 compute_specular_phong
(
    in uniforms_lighting u_lighting, 
    in vec3 color,
    in vec3 normal_vector, 
    in vec3 view_vector, 
    in vec3 light_vector,
    out float specular
)
{
    float shininess = u_lighting.shininess * 0.25;
    vec3 reflected_vector = - reflect(light_vector, normal_vector);

    specular = clamp(dot(reflected_vector, view_vector), 0.0, 1.0);
    specular = pow(specular, shininess);

    return mix(color, u_lighting.s_color, specular * u_lighting.ks);
}