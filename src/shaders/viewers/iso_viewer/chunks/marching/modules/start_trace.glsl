trace.block_lod = occumap.lod;

// take a backstep in order to compute the previouse trace 
trace.distance -= ray.min_step_distance;
trace.position -= ray.min_step_distance * ray.step_direction;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// sample the volume at previous step and save the trace
// Extract intensity and gradient from volume data in a single texture lookup
trace.sample_data = texture(textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
trace.sample_error = trace.sample_value - raymarch.sample_threshold;

// Compute the gradient and its norm in a single step
trace.gradient = mix(volume.min_gradient, volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.normal = -trace.gradient_direction;

// approximate trace step dericatives
#include "../../derivatives/compute_derivatives"

trace_prev = trace;

// take a frontstep to get in the starting position
trace.distance += ray.min_step_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// distances
trace.step_distance = ray.min_step_distance;
trace.step_scaling = 1.0;
trace.stepped_distance = 0.0;
