vec3 compute_ambient
(
    in uniforms_lighting u_lighting, 
    in vec3 color
)
{
    return u_lighting.ka * u_lighting.a_color * color;
}