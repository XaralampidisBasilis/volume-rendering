
coord = max_trace.voxel_texture_coords - u_volume.inv_dimensions * 0.5;

#pragma unroll_loop_start
for (int i = 0; i < 8; i++) {
    values[i] = textureOffset(u_textures.volume, coord, base_offsets[i]).r;
}
#pragma unroll_loop_end

// calculate gradient based on the sampled values 
max_trace.gradient = vec3(
    values[4] + values[5] + values[6] + values[7] - values[0] - values[1] - values[2] - values[3],
    values[2] + values[3] + values[6] + values[7] - values[0] - values[1] - values[4] - values[5],
    values[1] + values[3] + values[5] + values[7] - values[0] - values[2] - values[4] - values[6]
);

max_trace.gradient *= u_volume.inv_spacing * 0.25;
max_trace.gradient_magnitude = length(max_trace.gradient);
max_trace.gradient_direction = normalize(max_trace.gradient);
max_trace.derivative = dot(max_trace.gradient, ray.step_direction);