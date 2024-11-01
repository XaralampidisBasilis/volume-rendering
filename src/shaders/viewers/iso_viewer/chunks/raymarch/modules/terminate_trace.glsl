
// terminate trace position
trace_prev = trace;
trace.distance = ray.max_end_distance;
trace.position = ray.origin_position + ray.step_direction * trace.distance;
trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
trace.voxel_texture_coords = trace.position * volume.inv_size;

// terminate trace sample
trace.sample_data = texture(textures.volume, trace.voxel_texture_coords);
trace.sample_value = trace.sample_data.r;
trace.sample_error = trace.sample_value - raymarch.sample_threshold;

// terminate trace gradient
trace.gradient = mix(volume.min_gradient, volume.max_gradient, trace.sample_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.normal = -trace.gradient_direction;
#include "../../derivatives/compute_derivatives"

// compute skipped distance
trace.spanned_distance = ray.max_span_distance;
trace.skipped_distance = ray.max_span_distance;