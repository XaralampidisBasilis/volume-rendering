 
float compute_edge
(
    in uniforms_lighting u_lighting, 
    in vec3 view_vector, 
    in vec3 normal_vector
)
{
    float viewing_angle = abs(dot(view_vector, normal_vector));
    float edge_factor = pow(1.0 - viewing_angle, 0.3);

    if (edge_factor > u_lighting.edge_threshold) 
        return pow(map(u_lighting.edge_threshold, 1.0, edge_factor), 6.0);

    return 0.0;
}
 
 