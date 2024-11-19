
// save the initial trace state for potential rollback

trace = max_trace;

for (int i = 0; i < 10; i++, trace.step_count++) 
{    
    // update step distance based on gradient decent
    trace.step_scaling = trace.derivative / u_volume.max_gradient_length;
    trace.step_distance = ray.step_distance * trace.step_scaling;

    // update position
    trace.distance += trace.step_distance;
    trace.distance = clamp(trace.distance, ray.box_start_distance, ray.box_end_distance);
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // update sample
    trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;

    // update gradient
    #include './compute_trace_gradient"

    // update max trace
    if (max_trace.sample_value < trace.sample_value) max_trace = trace;
}
