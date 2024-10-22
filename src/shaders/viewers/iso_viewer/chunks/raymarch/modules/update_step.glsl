
// Precompute stepping for the first iteration
if (trace.steps == 0) {
    trace.stepping = u_raycast.min_stepping;
} else {
    // Compute stepping normally for subsequent iterations
    #include "../../stepping/compute_stepping"
}

// Update ray position for the next step
trace.spacing = trace.stepping * ray.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * inv_volume_size;