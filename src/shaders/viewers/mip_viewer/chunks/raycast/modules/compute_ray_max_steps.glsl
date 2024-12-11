
// compute the maximum allowed number of steps based on the min ray step distance

// ray.max_step_count = int(ceil(u_volume.size_length / mmin(u_volume.spacing * u_rendering.min_step_scaling)));
ray.max_step_count = int(ceil(ray.span_distance / ray.min_step_distance));
ray.max_skip_count = int(ceil(ray.span_distance / mmin(u_extremap.spacing)));

ray.max_step_count = min(ray.max_step_count, u_rendering.max_step_count);
ray.max_skip_count = min(ray.max_skip_count, u_rendering.max_skip_count);

ray.max_step_count = min(ray.max_step_count, MAX_TRACE_STEP_COUNT);
ray.max_skip_count = min(ray.max_skip_count, MAX_BLOCK_SKIP_COUNT);
