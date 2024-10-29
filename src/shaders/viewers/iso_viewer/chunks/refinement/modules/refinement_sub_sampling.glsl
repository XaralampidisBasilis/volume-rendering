/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param raymarch: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param u_sampler: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */

// take a backstep to do a refined traverse
parameters_trace final_trace = trace;
trace = trace_prev;

// calculate the refined substep
float sub_spacing = trace.step_distance / 6.0;  
vec4 volume_data;

// perform additional sampling steps to refine the hit point 
for (int i = 0; i < 5; i++, trace.steps++) 
{
    // move position forward by substep and sample the volume
    trace.position += sub_spacing * ray.step_direction;  
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // Extract intensity value from volume data
    volume_data = texture(u_sampler.volume, trace.voxel_texture_coords);
    trace.sample = volume_data.r;
    trace.sample_error = trace.sample - raymarch.sample_threshold;

    // if the sampled value exceeds the threshold, return early
    if (trace.sample_error > 0.0) break;
}

// extract gradient and distance
trace.gradient = mix(volume.min_gradient, volume.max_gradient, volume_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative_1st = dot(trace.gradient, ray.step_direction);

trace.distance = dot(trace.position - ray.origin_position, ray.step_direction);
trace.voxel_coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.start_distance;

// if there was not any refinement copy the final trace
if (abs(trace.sample_error) > abs(final_trace.error)) {
   trace = final_trace;
}


