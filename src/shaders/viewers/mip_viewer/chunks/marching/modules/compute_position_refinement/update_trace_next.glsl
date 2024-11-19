
trace_next = max_trace;

// compute distance
trace_next.distance += ray.max_step_distance / exp2(float(iter));
trace_next.distance = clamp(trace_next.distance, ray.box_start_distance, ray.box_end_distance);

// compute position
trace_next.position = ray.camera_position + ray.step_direction * trace_next.distance;
trace_next.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace_next.voxel_texture_coords = trace_next.position * u_volume.inv_size;

// compute sample
trace_next.sample_data = texture(u_textures.volume, trace_next.voxel_texture_coords);
trace_next.sample_value = trace_next.sample_data.r;

// compute gradient
coord = trace_next.voxel_texture_coords - u_volume.inv_dimensions * 0.5;

#pragma unroll_loop_start
for (int i = 0; i < 8; i++) {
    values[i] = textureOffset(u_textures.volume, coord, base_offsets[i]).r;
}
#pragma unroll_loop_end

// calculate gradient based on the sampled values 
trace_next.gradient = vec3(
    values[4] + values[5] + values[6] + values[7] - values[0] - values[1] - values[2] - values[3],
    values[2] + values[3] + values[6] + values[7] - values[0] - values[1] - values[4] - values[5],
    values[1] + values[3] + values[5] + values[7] - values[0] - values[2] - values[4] - values[6]
);

trace_next.gradient *= u_volume.inv_spacing * 0.25;
trace_next.gradient_magnitude = length(trace_next.gradient);
trace_next.gradient_direction = normalize(trace_next.gradient);
trace_next.derivative = dot(trace_next.gradient, ray.step_direction);