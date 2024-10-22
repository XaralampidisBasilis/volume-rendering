
// Update ray position for the next step
#include "../../stepping/compute_stepping"
trace.spacing = trace.stepping * ray.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * inv_volume_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);