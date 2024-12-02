
// coumpute the maximum allowed number of steps based on the min ray step distance

// ray.max_step_count = int(ceil(u_volume.size_length / mmin(u_volume.spacing * u_raymarch.min_step_scaling)));
ray.max_step_count = int(ceil(ray.span_distance / ray.min_step_distance));
ray.max_step_count = min(ray.max_step_count, u_raymarch.max_step_count);
ray.max_step_count = min(ray.max_step_count, MAX_STEP_COUNT);

float ray_min_skip_distance = mmin(u_distmap.spacing);
ray.max_skip_count = int(ceil(ray.span_distance / ray_min_skip_distance));
ray.max_skip_count = min(ray.max_skip_count, u_raymarch.max_skip_count);
ray.max_skip_count = min(ray.max_skip_count, MAX_SKIP_COUNT);
