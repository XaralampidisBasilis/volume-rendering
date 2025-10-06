
// start cell
#if SKIPPING_ENABLED == 1
cell.exit_distance = block.entry_distance;
cell.exit_position = block.entry_position;
cell.coords = ivec3(round(cell.exit_position));

#else
cell.exit_distance = ray.start_distance;
cell.exit_position = ray.start_position;
cell.coords = ivec3(round(cell.exit_position)); 
#endif

// start interpolant
#if INTERPOLATION_METHOD == 0
cubic.residuals[3] = sample_residue_trilinear(cell.exit_position);

#elif INTERPOLATION_METHOD == 1
quintic.residuals[3] = sample_residue_tricubic(cell.exit_position, quintic.features[3]);
#endif

#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif

