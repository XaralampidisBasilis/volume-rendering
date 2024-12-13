

// Compute dual voxel from trace.position
dual_voxel.coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);
dual_voxel.min_position = (vec3(dual_voxel.coords) + 0.5) * u_volume.spacing;
dual_voxel.max_position = (vec3(dual_voxel.coords) + 1.5) * u_volume.spacing;

// Compute sample trace distances
vec2 trace_bounds = intersect_box(dual_voxel.min_position, dual_voxel.max_position, camera.position, ray.step_direction);
trace_distances = mmix(trace_bounds.x, trace_bounds.y, sample_distances);

// Compute sample voxel values
voxel_values.x = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.x).r;
voxel_values.y = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.y).r;
voxel_values.z = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.z).r;
voxel_values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.w).r;

// Compute solution
vec4 coefficients = sample_matrix * voxel_values;
vec3 solution_distances = cubic_solver(coefficients, u_rendering.min_value);
vec3 is_inside = inside_closed(0.0, 1.0, solution_distances);
solution_distances = mmix(1.0, solution_distances, is_inside);

// Update trace 
trace.distance = mix(trace_bounds.x, trace_bounds.y, mmin(solution_distances));
trace.position = camera.position + ray.step_direction * trace.distance; 

// Update voxel
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
voxel.texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);
voxel.value = voxel.texture_sample.r;
voxel.gradient = voxel.texture_sample.gba;
voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

// Update error
trace.error = u_rendering.min_value - voxel.value;