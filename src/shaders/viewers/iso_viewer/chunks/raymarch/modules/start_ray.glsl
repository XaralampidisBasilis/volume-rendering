
ray.intersected = false;

// coumpute the maximum allowed number of steps based on the min ray step distance
ray.max_step_count = int(ceil(ray.span_distance / ray.min_step_distance));
ray.max_step_count = min(ray.max_step_count, raymarch.max_step_count);

// coumpute the maximum allowed number of skips based on the current occumap dimensions
ray.max_skip_count = mmax(occumap.dimensions);
ray.max_skip_count = min(ray.max_skip_count, raymarch.max_skip_count);
