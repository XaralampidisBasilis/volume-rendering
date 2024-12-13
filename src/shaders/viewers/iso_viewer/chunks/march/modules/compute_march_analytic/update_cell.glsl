

// Compute cell coords from trace position
dual_voxel.coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);

// Compute dual_voxel box in model coords
dual_voxel.min_position = (vec3(dual_voxel.coords) + 0.5 - MILLI_TOLERANCE) * u_volume.spacing;
dual_voxel.max_position = (vec3(dual_voxel.coords) + 1.5 + MILLI_TOLERANCE) * u_volume.spacing;

// update position
trace_bounds = intersect_box(dual_voxel.min_position, dual_voxel.max_position, camera.position, ray.step_direction);

// update trace distances
trace_distances.x = trace_distances.w;
trace_distances.yzw = mmix(trace_bounds.x, trace_bounds.y, sample_distances.yzw);

// update voxel values
voxel_values.x = voxel_values.w;
voxel_values.y = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.y).r;
voxel_values.z = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.z).r;
voxel_values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.w).r;

// compute trilinear interpolation cubic coefficients for the current cell
vec4 coefficients = sample_matrix * voxel_values;

// check if there is intersection
trace.intersected = is_cubic_solvable(coefficients, u_rendering.min_value, 0.0, 1.0);


