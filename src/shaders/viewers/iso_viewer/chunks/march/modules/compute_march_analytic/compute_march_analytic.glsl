

const vec4 t = vec4(0.0, 1.0/3.0, 2.0/3.0, 1.0);
const mat4 A = mat4(
    1.0, -5.5, 9.0, -4.5,
    0.0, 9.0, -22.5, 13.5,
    0.0, -4.5, 18.0, -13.5,
    0.0, 1.0, -4.5, 4.5 
);

Voxel dual_voxel = set_voxel();
vec4 sample_values = vec4(0.0);

// start march
trace.distance = ray.start_distance;
trace.position = ray.start_position;
prev_trace = trace;

for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count; trace.step_count++) 
{
    // Compute dual voxel coords from trace position
    dual_voxel.coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);

    // Compute dual_voxel box in model coords
    dual_voxel.min_position = (vec3(dual_voxel.coords) + 0.5 - MILLI_TOLERANCE) * u_volume.spacing;
    dual_voxel.max_position = (vec3(dual_voxel.coords) + 1.5 + MILLI_TOLERANCE) * u_volume.spacing;

    // Update position
    vec2 distance_bounds = intersect_box(dual_voxel.min_position, dual_voxel.max_position, camera.position, ray.step_direction);
    vec4 sample_distances = mmix(distance_bounds.x, distance_bounds.y, t);

    // Update value samples
    sample_values.x = sample_values.w;
    sample_values.yzw = vec3(
        texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * sample_distances.y).r,
        texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * sample_distances.z).r,
        texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * sample_distances.w).r
    );
       
    // Compute cubic coefficients

    vec4 coeffs = A * sample_values;
    debug.variable1 = vec4(vec3(mmin(abs(coeffs)) <= MILLI_TOLERANCE), 1.0);

    vec3 trace_distances = cubic_solver(coeffs, u_rendering.min_value);
    vec3 is_inside = inside_open(0.0, 1.0, trace_distances);
    trace.intersected = some(is_inside) > MICRO_TOLERANCE;

    // check condition
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
    trace.distance = distance_bounds.y;
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
