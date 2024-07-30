
void compute_orientation
(
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient, 
    in uniforms_sampler u_sampler,
    inout parameters_ray ray
)
{
    vec3 forward_pos = ray.position + ray.normal * ray.step;
    vec3 backward_pos = ray.position - ray.normal * ray.step;

    vec3 positions[2] = vec3[2](backward_pos, forward_pos);
    int exists[2];

    for (int i = 0; i < 2; i++)
    {
        vec4 texture_data = texture(u_sampler.volume, positions[i]);
        float gradient_length = length(texture_data.gba);
        float value = texture_data.r;

        exists[i] = int(value > u_raycast.threshold && gradient_length > u_gradient.threshold);
    }

    // Correct the orientation of the normal vector
    if (exists[0] != exists[1])
    {
        // If the backward position exists but the forward does not, invert the normal
        ray.normal *= float(exists[1] - exists[0]);
    }}