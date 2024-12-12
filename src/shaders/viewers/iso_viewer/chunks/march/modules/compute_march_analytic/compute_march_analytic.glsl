

const vec4 t = vec4(0.0, 1.0/3.0, 2.0/3.0, 1.0);
const mat4 A = mat4(
    1.0, -5.5, 9.0, -4.5,
    0.0, 9.0, -22.5, 13.5,
    0.0, -4.5, 18.0, -13.5,
    0.0, 1.0, -4.5, 4.5 
);

// const vec4 t = vec4(0.125, 0.375, 0.625, 0.875);
// const mat4 A = mat4(
//  105.0, -568.0,   960.0,   -512.0,
// -105.0, 1128.0, -2496.0,   1536.0,
//   63.0, -744.0, 2112.0, -1536.0,
// -15.0, 184.0, -576.0,   512.0 
// ) / 48.0;




// start march
trace.distance = ray.start_distance;
trace.position = ray.start_position;
prev_trace = trace;

for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count; trace.step_count++) 
{
    // Compute doxel coords from trace position
    doxel.coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);

    // Compute doxel box in model coords
    doxel.min_position = (vec3(doxel.coords) + 0.5) * u_volume.spacing;
    doxel.max_position = (vec3(doxel.coords) + 1.5) * u_volume.spacing;

    // Update position
    vec2 distance_bounds = intersect_box(doxel.min_position, doxel.max_position, camera.position, ray.step_direction);
    vec4 sample_distances = mmix(distance_bounds.x, distance_bounds.y, t);

    // Update values
    vec4 values = vec4(
        texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.x) * u_volume.inv_size).r,
        texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.y) * u_volume.inv_size).r,
        texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.z) * u_volume.inv_size).r,
        texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.w) * u_volume.inv_size).r
    );

    // Compute cubic coefficients

    vec4 coeffs = A * values;


    /* Tests

        // Seems okey
        // float tau = map(distance_bounds.x, distance_bounds.y, trace.distance);
        // float val_aprx = dot(coeffs, vec4(1.0, tau, pow2(tau), pow3(tau)));
        // float val = texture(u_textures.taylor_map, (camera.position + ray.step_direction * trace.distance) * u_volume.inv_size).r;
        // vec3 err = mmix(BLUE_COLOR, BLACK_COLOR, RED_COLOR, map(-1.0, 1.0, (val_aprx - val)));
        // debug.variable1 = vec4(err, 1.0); // the error is close to zero


        // Seems okey, there are some salt pepper errors
        // float val = texture(u_textures.taylor_map, (camera.position + ray.step_direction * trace.distance) * u_volume.inv_size).r;
        // coeffs[0] -= val;
        // vec3 trace_distances = cubic_roots(coeffs);
        // float tau = map(distance_bounds.x, distance_bounds.y, trace.distance);
        // debug.variable1 = vec4(vec3(mmin(abs(trace_distances - tau))), 1.0);

        // Seems okey, there are some salt pepper errors
        // coeffs[0] -= u_rendering.min_value;
        // vec3 tau = cubic_roots(coeffs);
        // coeffs[0] += u_rendering.min_value;
        // vec3 vals = vec3(
        //     dot(coeffs, vec4(1.0, tau.x, pow2(tau.x), pow3(tau.x))),
        //     dot(coeffs, vec4(1.0, tau.y, pow2(tau.y), pow3(tau.y))),
        //     dot(coeffs, vec4(1.0, tau.z, pow2(tau.z), pow3(tau.z)))
        // );
        // vec3 errs = vec3(
        //     abs(u_rendering.min_value - vals.x),
        //     abs(u_rendering.min_value - vals.y),
        //     abs(u_rendering.min_value - vals.z)
        // );
        // debug.variable1 = vec4(vals, 1.0);
        // debug.variable2 = vec4(errs, 1.0);

    */
    

    coeffs[0] -= u_rendering.min_value;
    int num_roots;
    vec3 trace_distances = cubic_roots(coeffs, num_roots);
    // debug.variable1 = vec4(vec3(float(num_roots) / 3.0), 1.0);
    // debug.variable2 = vec4(vec3(lessThanEqual(trace_distances, vec3(0.0))), 1.0);
    // debug.variable3 = vec4(vec3(lessThanEqual(trace_distances, vec3(1.0))), 1.0);
    // debug.variable3 = vec4(vec3(greaterThan(trace_distances, vec3(1.0))), 1.0);

    // // THERE IS A PROBLEM SOMEWHERE HERE
    vec3 is_inside = inside_open(0.0, 1.0, trace_distances);
    debug.variable1 = vec4(vec3(is_inside), 1.0);

    float is_solution = some(is_inside);
    debug.variable2 = vec4(vec3(is_solution), 1.0);

    // check condition
    trace.intersected = is_solution > 0.5;
    if (trace.intersected)
    {
        trace_distances = mmix(1.0, trace_distances, is_inside);
        trace_distances = mmix(distance_bounds.x, distance_bounds.y, trace_distances);
        trace.distance = mmin(trace_distances);
        trace.position = camera.position + ray.step_direction * trace.distance; 

        // update position
        voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
        voxel.texture_coords = trace.position * u_volume.inv_size;
        vec4 texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);

        voxel.value = texture_sample.r;
        voxel.gradient = texture_sample.gba;
        voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

        trace.error = u_rendering.min_value - voxel.value;

        break;
    }

    // update previous
    prev_trace = trace;

    // update position
    trace.distance = distance_bounds.y + u_volume.spacing_length * MILLI_TOLERANCE;
    trace.position = camera.position + ray.step_direction * trace.distance; 

    // update conditions
    trace.terminated = trace.distance > ray.end_distance;
    trace.exhausted = trace.step_count >= ray.max_step_count;

    // check conditions
    if (trace.terminated || trace.exhausted) 
    {
        break;
    }
}   
