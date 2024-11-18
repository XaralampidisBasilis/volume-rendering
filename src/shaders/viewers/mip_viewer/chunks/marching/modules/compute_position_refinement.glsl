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

// save the initial trace state for potential rollback
trace = trace_max;

for (int i = 0; i < int(u_debugger.variable3); i++) 
{
    // use gradient decent to update the step distance
    trace.step_distance = u_debugger.variable1 * trace.derivative;
    trace.step_distance = min(trace.step_distance, ray.max_step_distance);

    // linearly interpolate positions based on sample 
    trace.distance += trace.step_distance;
    trace.distance = clamp(trace.distance, ray.box_start_distance, ray.box_end_distance);
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // sample volume at current position
    trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;

    // sample gradient
    trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
    trace.derivative = dot(trace.gradient, ray.step_direction);

    // update max trace
    if (trace_max.sample_value < trace.sample_value) trace_max = trace;

    trace.step_count++;
}
