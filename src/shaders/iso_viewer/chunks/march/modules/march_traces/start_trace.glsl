
// start trace
#if SKIPPING_ENABLED == 1

    trace.distance = block.entry_distance - ray.spacing * random(block.entry_position);
    trace.position = camera.position + ray.direction * trace.distance;

#else

    trace.distance = ray.start_distance - ray.spacing * random(ray.start_position);
    trace.position = camera.position + ray.direction * trace.distance; 

#endif

// start interpolant
#if INTERPOLATION_METHOD == 0

    trace.residue = sample_residue_trilinear(trace.position);

#endif
#if INTERPOLATION_METHOD == 1

    trace.residue = sample_residue_tricubic(trace.position);

#endif

#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif

