

const vec4 t = vec4(0.125, 0.375, 0.625, 0.875);
const mat4 A = mat4(
 105.0, -568.0,   960.0,   -512.0,
-105.0, 1128.0, -2496.0,   1536.0,
  63.0, -744.0, 2112.0, -1536.0,
-15.0, 184.0, -576.0,   512.0 
) / 48.0;


// start march
trace.distance = ray.start_distance;
trace.position = ray.start_position;
prev_trace = trace;

// for (trace.step_count = 0; trace.step_count < u_rendering.max_step_count; trace.step_count++) 
// {
//     // Compute dual voxel from trace position
//     doxel.coords = ivec3(trace.position * u_volume.inv_spacing - 0.5);
//     doxel.min_position = (vec3(doxel.coords) + 0.5 - MILLI_TOLERANCE) * u_volume.spacing;
//     doxel.max_position = (vec3(doxel.coords) + 1.5 + MILLI_TOLERANCE) * u_volume.spacing;

//     // Update position
//     vec2 doxel_distances = intersect_box(doxel.min_position, doxel.max_position, camera.position, ray.step_direction);
//     vec4 sample_distances = mmix(doxel_distances.x, doxel_distances.y, t);

//     // Update values
//     vec4 values = vec4(
//         texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.x) * u_volume.inv_size).r,
//         texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.y) * u_volume.inv_size).r,
//         texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.z) * u_volume.inv_size).r,
//         texture(u_textures.taylor_map, (camera.position + ray.step_direction * sample_distances.w) * u_volume.inv_size).r
//     );

//     // Compute cubic coefficients
//     vec4 coeffs = A * values;
//     coeffs[0] -= u_rendering.min_value;

//     // Solve for isosurface threshold
//     vec3 trace_distances = cubic_roots(coeffs);
//     // vec3 is_inside = inside(0.0, 1.0, trace_distances);
//     // vec3 is_inside = vec3(greaterThan(trace_distances, vec3(0.0))) * vec3(lessThan(trace_distances, vec3(1.0)));
//     // float is_solution = some(is_inside);

//     // debug.variable1 = vec4(trace_distances, 1.0);
//     // debug.variable2 = vec4(vec3(greaterThan(trace_distances, vec3(0.0))) * vec3(lessThan(trace_distances, vec3(1.0))), 1.0);
//     // debug.variable3 = vec4(1.0 - max(step(trace_distances, vec3(0.0)), step(vec3(1.0), trace_distances)), 1.0);

//     // debug.variable2 = vec4( (step(trace_distances, vec3(0.0)) - vec3(lessThanEqual(trace_distances, vec3(0.0)))) , 1.0);
//     // debug.variable3 = vec4( (step(vec3(1.0), trace_distances) - vec3(greaterThanEqual(trace_distances, vec3(1.0)))) , 1.0);
 
//     // debug.variable3 = vec4( (1.0 - step(trace_distances, vec3(0.0 + u_debugging.variable1)) - vec3(greaterThan(trace_distances, vec3(0.0)))) , 1.0);


//     debug.variable1 = vec4( (1.0 - step(vec3(1.0), trace_distances) - vec3(lessThan(trace_distances, vec3(1.0)))   ) , 1.0);
//     // debug.variable2 = vec4( 1.0 - step(vec3(1.0), trace_distances) , 1.0);
//     // debug.variable3 = vec4( vec3(lessThan(trace_distances, vec3(1.0))) , 1.0);


//     // // check condition
//     // if (trace.intersected)
//     // {
//     //     trace_distances = mmix(1.0, trace_distances, is_inside);
//     //     trace_distances = mmix(doxel_distances.x, doxel_distances.y, sort(trace_distances));
//     //     trace.distance = trace_distances.x;
//     //     trace.position = camera.position + ray.step_direction * trace.distance; 

//     //     // update position
//     //     voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
//     //     voxel.texture_coords = trace.position * u_volume.inv_size;
//     //     vec4 texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);

//     //     voxel.value = texture_sample.r;
//     //     voxel.gradient = texture_sample.gba;
//     //     voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

//     //     break;
//     // }

//     // update previous
//     prev_trace = trace;

//     // update position
//     trace.distance = doxel_distances.y;
//     trace.position = camera.position + ray.step_direction * trace.distance; 

//     // update conditions
//     trace.terminated = trace.distance > ray.end_distance;
//     trace.exhausted = trace.step_count >= ray.max_step_count;

//     // check conditions
//     if (trace.terminated || trace.exhausted) 
//     {
//         break;
//     }
// }   
