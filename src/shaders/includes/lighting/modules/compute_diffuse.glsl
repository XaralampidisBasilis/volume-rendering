vec3 compute_diffuse
(
    in uniforms_lighting u_lighting, 
    in vec3 color,
    in vec3 normal_vector, 
    in vec3 light_vector,
    out float lambertian
)
{
    lambertian = clamp(dot(normal_vector, light_vector), 0.0, 1.0);

    return lambertian * u_lighting.kd * u_lighting.d_color * color;
}