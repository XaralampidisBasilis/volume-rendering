
#include "./start_march"

for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count; trace.step_count++) 
{

    #include "./update_solution"

    if (trace.intersected)
    {
        break;
    }

    #include "./update_trace"

    if (trace.terminated || trace.exhausted) 
    {
        break;
    }

    #include "./update_cell"

}   

if (trace.intersected)
{
     // Compute dual voxel coords from trace position
    dual_voxel.coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);

    // Compute dual_voxel box in model coords
    dual_voxel.min_position = (vec3(dual_voxel.coords) + 0.5) * u_volume.spacing;
    dual_voxel.max_position = (vec3(dual_voxel.coords) + 1.5) * u_volume.spacing;

    // Update position
    vec2 distance_bounds = intersect_box(dual_voxel.min_position, dual_voxel.max_position, camera.position, ray.step_direction);
    trace_distances = mmix(distance_bounds.x, distance_bounds.y, sample_distances);

    // Update value samples
    voxel_values.x = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.x).r;
    voxel_values.y = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.y).r;
    voxel_values.z = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.z).r;
    voxel_values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * trace_distances.w).r;

    // Compute cubic coefficients
    vec4 coeffs = sample_matrix * voxel_values;
    vec3 solution_distances = cubic_solver(coeffs, u_rendering.min_value);
    vec3 is_inside = inside_closed(0.0, 1.0, solution_distances);
    trace.intersected = some(is_inside) > MICRO_TOLERANCE;

    solution_distances = mmix(1.0, solution_distances, is_inside);
    trace.distance = mix(distance_bounds.x, distance_bounds.y, mmin(solution_distances));
    trace.position = camera.position + ray.step_direction * trace.distance; 

    // update position
    voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
    voxel.texture_coords = trace.position * u_volume.inv_size;
    vec4 texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);

    voxel.value = texture_sample.r;
    voxel.gradient = texture_sample.gba;
    voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

    trace.error = u_rendering.min_value - voxel.value;
}


#include "../end_march"