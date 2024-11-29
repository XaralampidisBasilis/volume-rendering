
// coumpute the maximum allowed number of steps based on the min ray step distance
// ray.max_step_count = int(ceil(ray.span_distance / ray.min_step_distance));
ray.step_count = 0;
ray.max_step_count = int(ceil(u_volume.size_length / mmin(u_volume.spacing * u_raymarch.min_step_scaling)));
ray.max_step_count = mmin(ray.max_step_count, u_raymarch.max_step_count, MAX_STEP_COUNT);

// coumpute the maximum allowed number of skips based on the current occumap dimensions
ray.skip_count = 0;
ray.max_skip_count = sum(u_occumaps.base_dimensions) + 1;
ray.max_skip_count = mmin(ray.max_skip_count, u_raymarch.max_skip_count, MAX_SKIP_COUNT);
