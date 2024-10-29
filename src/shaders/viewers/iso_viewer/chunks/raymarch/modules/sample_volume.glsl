
// Extract intensity and gradient from volume data in a single texture lookup
vec4 volume_texture_data = texture(textures.volume, trace.voxel_texture_coords);
trace.sample_value = volume_texture_data.r;
trace.sample_error = trace.sample_value - raymarch.sample_threshold;

// Compute the gradient and its norm in a single step
trace.gradient = mix(volume.min_gradient, volume.max_gradient, volume_texture_data.gba);
trace.gradient_magnitude = length(trace.gradient);
trace.gradient_direction = normalize(trace.gradient);
trace.normal = -trace.gradient_direction;
#include "../../derivatives/compute_derivatives"
