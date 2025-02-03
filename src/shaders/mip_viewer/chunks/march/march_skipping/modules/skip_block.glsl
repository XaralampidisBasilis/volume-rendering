
trace.distance = block.exit_distance;
trace.position = camera.position + ray.direction * trace.distance;
trace.terminated = trace.distance > ray.end_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_skips += 1;
#endif