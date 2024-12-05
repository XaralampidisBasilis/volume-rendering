
// Define bisection bounds
vec2 trace_values = vec2(prev_trace.value, trace.value);
vec2 trace_distances = vec2(prev_trace.distance, trace.distance);
trace_distances = clamp(trace_distances, ray.box_start_distance, ray.box_end_distance);
Trace trace_tmp = trace;

// Compute iterative bisection
for (int iter = 0; iter < 10; iter++, trace.step_count++) 
{
    // update interpolation
    float interpolation = map(trace_values.x, trace_values.y, u_rendering.min_value);

    // update position
    trace.distance = mix(trace_distances.x, trace_distances.y, interpolation);
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texels = trace.position * u_volume.inv_size;
    vec4 taylormap_sample = texture(u_textures.taylormap, trace.voxel_texels);

    // update value
    trace.value = taylormap_sample.r;
    trace.value_error = trace.value - u_rendering.min_value;
    float interval = step(0.0, trace.value_error);

    // update gradient
    trace.gradient = taylormap_sample.gba;
    trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.gradient);
    trace.gradient_magnitude = length(trace.gradient);
    trace.derivative = dot(trace.gradient, ray.step_direction);
    trace.normal = -normalize(trace.gradient);
        
    // update interval
    trace_values = mix(
        vec2(trace.value, trace_values.y), 
        vec2(trace_values.x, trace.value), 
        interval);

    trace_distances = mix(
        vec2(trace.distance, trace_distances.y), 
        vec2(trace_distances.x, trace.distance), 
        interval);
}

// Rollback if greater absolute error
if (abs(trace.value_error) > abs(trace_tmp.value_error)) 
{
    trace = trace_tmp;
}

#include "./refine_trace_position_copy"