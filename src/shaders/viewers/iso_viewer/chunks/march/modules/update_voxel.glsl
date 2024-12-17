
// update previous
prev_voxel = voxel;

// update position
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);

// update value
voxel.value = voxel.texture_sample.r;
voxel.error = voxel.value - u_rendering.threshold_value;
trace.intersected = voxel.value > u_rendering.threshold_value;

// update gradient
voxel.gradient = voxel.texture_sample.gba;
voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

