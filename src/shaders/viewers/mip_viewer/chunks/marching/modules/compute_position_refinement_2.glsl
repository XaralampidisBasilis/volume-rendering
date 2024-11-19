
// update trace
trace = max_trace;

// refine max trace gradient
#include './compute_trace_gradient"
max_trace = trace;

// update trace based on gradient direction

trace.distance += ray.step_distance * sign(max_trace.derivative);
trace.distance = clamp(trace.distance, ray.box_start_distance, ray.box_end_distance);
trace.position = ray.camera_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;

#include './compute_trace_gradient"

// select intervals
bool select = max_trace.derivative > 0.0;
vec2 derivatives = select ? vec2(max_trace.derivative, trace.derivative) : vec2(trace.derivative, max_trace.derivative);
vec2 distances = select ? vec2(max_trace.distance, trace.distance) : vec2(trace.distance, max_trace.distance);

for (int i = 0; i < 5; i++) 
{
    // compute sample linear interpolation factor
    float lerp = map(derivatives.x, derivatives.y, 0.0);

    // linearly interpolate positions based on sample 
    trace.distance = mix(distances.x, distances.y, lerp);
    trace.position = ray.camera_position + ray.step_direction * trace.distance;
    trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
    trace.voxel_texture_coords = trace.position * u_volume.inv_size;

    // sample volume at start position
    trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
    trace.sample_value = trace.sample_data.r;

    // sample gradient
    #include './compute_trace_gradient"

    // select interval based on sample error 
    bool select = trace.derivative > 0.0;
    derivatives = select ? vec2(derivatives.x, trace.derivative) : vec2(trace.derivative, derivatives.y);
    distances = select ? vec2(distances.x, trace.distance) : vec2(trace.distance, distances.y);

    trace.step_count++;

    if (max_trace.sample_value < trace.sample_value) max_trace = trace;
}