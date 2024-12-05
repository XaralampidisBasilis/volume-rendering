


// Set parameters
vec3 cell_size = u_volume.spacing;
ivec3 cell_min_coords;
vec3 cell_min_position;
vec3 cell_max_position;
float cell_values[8];

// Save trace for rollback
Trace trace_tmp = trace;

// Compute the analytical solution for the isosurface threshold based on trilinear interpolation
for (int iter = 0; iter < int(u_debugging.variable3); iter++)
{
    // Update cell based on trace position
    cell_min_coords = ivec3(trace.position / cell_size - 0.5);
    cell_min_position = (vec3(cell_min_coords) + 0.5) * cell_size;
    cell_max_position = cell_min_position + cell_size;

    // Compute cell vertex values 
    #pragma unroll_loop_start
    for (int i = 0; i < 8; i++) {
        cell_values[i] = textureOffset(u_textures.taylormap, cell_min_position * u_volume.inv_size, binary_offsets[i]).r;
    }
    #pragma unroll_loop_end

    // Compute ray trilinear polynomial coefficients based on values and ray
    vec3 direction = ray.step_direction / cell_size;
    vec3 origin = (trace.position - cell_min_position) / cell_size;
    vec4 coeffs = ray_trilinear_cubic_coeffs(cell_values, origin, direction);

    // debug.variable1 = vec4(vec3(inside_box_inclusive(cell_min_position, cell_max_position, trace.position)), 1.0);
    // debug.variable2 = vec4(vec3(abs(coeffs.x - trace.value) / 0.01), 1.0);
    
    // Compute the solution where the trilinear polynomial equals to the isosurface threshold
    coeffs[0] -= u_rendering.min_value;
    // coeffs *= vec4(1.0, ray.step_distance, pow2(ray.step_distance), pow3(ray.step_distance));
    vec3 step_distances = cubic_roots(coeffs);

    // Compute ray distance boundaries inside cell
    vec3 min_position = cell_min_position - 0.1 * cell_size;
    vec3 max_position = cell_max_position + 0.1 * cell_size;
    vec2 step_bounds = intersect_box(min_position, max_position, trace.position, ray.step_direction);

    debug.variable1 = vec4(vec3(clamp(step_distances, step_bounds.x, step_bounds.y) / ray.step_distance), 1.0);

    // Update trace distance based on the shortest distance found inside the cell
    trace.step_distance = clamp(step_distances, step_bounds.x, step_bounds.y).x;
    trace.distance += trace.step_distance;

    // Update position
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texels = trace.position * u_volume.inv_size;
    vec4 texture_sample = texture(u_textures.taylormap, trace.voxel_texels);

    // Update value
    trace.value = texture_sample.r;
    trace.value_error = trace.value - u_rendering.min_value;

    // Update gradient
    trace.gradient = texture_sample.gba;
    trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.gradient);
    trace.gradient_magnitude = length(trace.gradient);
    trace.derivative = dot(trace.gradient, ray.step_direction);
    trace.normal = -trace.gradient_direction;

    // Termination condition
    if (abs(trace.value_error) < CENTI_TOLERANCE) break;
}

// Rollback if no improvement
// if (abs(trace.value_error) > abs(trace_tmp.value_error)) 
// {
//     trace = trace_tmp;
// }
