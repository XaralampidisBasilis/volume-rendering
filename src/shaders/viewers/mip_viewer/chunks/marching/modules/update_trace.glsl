
trace.step_count++;

// update position
trace.distance += trace.step_distance;
trace.position = ray.camera_position + ray.step_direction * trace.distance; 
trace.voxel_coords = ivec3(trace.position * u_volume.inv_spacing);
trace.voxel_texture_coords = trace.position * u_volume.inv_size;

// update value
trace.sample_data = texture(u_textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;

// update gradient
trace.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.derivative = dot(trace.gradient, ray.step_direction);

// update step
#include "./compute_trace_adaptive_step"

// update max trace
if (trace.sample_value > max_trace.sample_value) 
{
    max_trace = trace;
}
