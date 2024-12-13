
// start sampling constants
const vec4 sample_distances = vec4(0.0, 0.333333332, 0.666666667, 1.0);
const mat4 sample_matrix = mat4(
     1.0, -5.5,   9.0,   -4.5,
     0.0,  9.0, -22.5,   13.5,
     0.0, -4.5, 18.0, -13.5,
    0.0, 1.0, -4.5,   4.5 
);

// start dual voxel
dual_voxel.coords = ivec3(ray.start_position * u_volume.inv_spacing - 0.5);
dual_voxel.min_position = (vec3(dual_voxel.coords) + 0.5 - MILLI_TOLERANCE) * u_volume.spacing;
dual_voxel.max_position = (vec3(dual_voxel.coords) + 1.5 + MILLI_TOLERANCE) * u_volume.spacing;

// start trace
vec2 trace_bounds = intersect_box(dual_voxel.min_position, dual_voxel.max_position, camera.position, ray.step_direction);
trace.position = camera.position + ray.step_direction * trace_bounds.x;
prev_trace = trace;

// start sampling arrays
vec4 trace_distances = mmix(trace_bounds.x, trace_bounds.y, sample_distances);
vec4 voxel_values = vec4
(
    texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.x).r,
    texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.y).r,
    texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.z).r,
    texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.w).r
);

// compute trilinear interpolation cubic coefficients for the current cell
vec4 coefficients = sample_matrix * voxel_values;
trace.intersected = is_cubic_solvable(coefficients, u_rendering.min_value, 0.0, 1.0);


