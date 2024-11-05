
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

// check for intersection
ray.intersected = trace.sample_error > 0.0 && trace.gradient_magnitude > raymarch.gradient_threshold;