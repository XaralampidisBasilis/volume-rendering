// Set parameters
ivec3 cell_min_coords;
vec3 cell_min_position;
vec3 cell_max_position;
float cell_values[8];

// Compute the analytical solution for the isosurface threshold based on trilinear interpolation
if (u_debugging.variable1 > 0.0)
{
    // Update cell based on trace position
    cell_min_coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);
    cell_min_position = (vec3(cell_min_coords) + 0.5) * u_volume.spacing;
    cell_max_position = cell_min_position + u_volume.spacing;

    // Compute cell vertex values 
    #pragma unroll_loop_start
    for (int i = 0; i < 8; i++) {
        cell_values[i] = textureOffset(u_textures.taylormap, cell_min_position * u_volume.inv_size, binary_offsets[i]).r;
    }
    #pragma unroll_loop_end

    // Compute ray trilinear polynomial coefficients based on values and ray
    vec3 direction = ray.step_direction * u_volume.inv_spacing;
    float scale = length(direction);
    direction /= scale;

    vec3 origin = (trace.position - cell_min_position) * u_volume.inv_spacing;
    vec4 coeffs = ray_trilinear_cubic_coeffs(cell_values, origin, direction);

    // Compute the solution where the trilinear polynomial equals to the isosurface threshold
    coeffs[0] -= u_rendering.min_value;
    vec3 step_distances = cubic_roots(coeffs);
    step_distances /= scale;

    // Compute ray distance boundaries inside cell
    vec2 step_bounds = intersect_box(cell_min_position, cell_max_position, trace.position, ray.step_direction);

    // Update trace distance based on the shortest distance found inside the cell
    vec3 is_inside = inside(step_bounds.x, step_bounds.y, step_distances);
    float is_solution = prod(is_inside);

    debug.variable1 = vec4(vec3(is_solution), 1.0);
    if (is_solution > 0.0)
    {
        // Filter solution
        step_distances = mix(vec3(step_bounds.y), step_distances, is_inside);
        trace.step_distance = sort(step_distances).x;

        // Update position
        trace.distance += trace.step_distance;
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
        trace.normal = -normalize(trace.gradient);
    }
    
}
