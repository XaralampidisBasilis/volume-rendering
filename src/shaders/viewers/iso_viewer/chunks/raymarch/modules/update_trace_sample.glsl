
// Extract intensity and gradient from volume data in a single texture lookup
vec4 volume_texture_data = texture(u_sampler.volume, trace.texel);
trace.value = volume_texture_data.r;
trace.error = trace.value - raycast_threshold;

// Compute the gradient and its norm in a single step
trace.gradient = mix(u_gradient.min, u_gradient.max, volume_texture_data.gba);
trace.normal = -normalize(trace.gradient);
#include "../../derivatives/compute_derivatives"