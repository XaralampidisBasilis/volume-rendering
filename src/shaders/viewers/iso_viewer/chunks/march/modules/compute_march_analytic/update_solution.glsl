
// compute trilinear interpolation cubic coefficients for the current cell
vec4 coefficients = sample_matrix * voxel_values;

// solve the cubic polynomial for the isosurface threshold
vec3 solution_distances = cubic_solver(coefficients, u_rendering.min_value);

// check if there is a solution inside the current cell
vec3 is_inside = inside_open(0.0, 1.0, solution_distances);

// if there are some solutions declare intersection
trace.intersected = some(is_inside) > MICRO_TOLERANCE;

debug.variable1 = vec4(vec3(is_cubic_solvable(coefficients, u_rendering.min_value, 0.0, 1.0)), 1.0);
