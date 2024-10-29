/**
 * Refines the hit point by performing additional sampling steps.
 *
 * @param raymarch: struct containing raycast-related uniforms.
 * @param u_gradient: struct containing gradient-related uniforms.
 * @param textures: struct containing volume-related uniforms.
 * @param ray_step: step vector for raycasting increments.
 * @param hit_position: inout vec3 where the refined position of the intersection will be stored.
 * @param hit_sample: output float where the refined value at the intersection will be stored.
 * @param hit_normal: output vec3 where the refined normal at the intersection will be stored.
 */

// take a backstep to do a refined traverse
Trace trace_tmp = trace;
trace = trace_prev;

// calculate the refined substep
float trace_step_distance = trace.step_distance / 6.0;  

// perform additional sampling steps to refine the hit point 
for (int i = 0; i < 5; i++, trace.step_count++) 
{
    // move position forward by substep and sample the volume
    trace.position += trace_step_distance * ray.step_direction;  
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // Extract intensity value from volume data
    trace.sample_data = texture(textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;
    trace.sample_error = trace.sample_value - raymarch.sample_threshold;

    // if the sampled value exceeds the threshold, return early
    if (trace.sample_error > 0.0) break;
}

// extract gradient and distance
trace.gradient = mix(volume.min_gradient, volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.normal = - normalize(trace.gradient);
trace.derivative_1st = dot(trace.gradient, ray.step_direction);

trace.distance = dot(trace.position - ray.origin_position, ray.step_direction);
trace.voxel_coords = ivec3(trace.position * volume.inv_spacing);

// if there was not any refinement copy the final trace
if (abs(trace.sample_error) > abs(trace_tmp.sample_error)) trace = trace_tmp;



