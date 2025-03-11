
// COMPUTE DEBUG

// num fetches
vec4 debug_stats_num_fetches = to_color(float(stats.num_fetches) / float(MAX_VOXELS) * 2.0);

// num steps
vec4 debug_stats_num_steps = to_color(float(stats.num_steps) / float(MAX_VOXELS));

// PRINT DEBUG

switch (u_debugging.option - debug_slot_stats)
{
    case 1: fragColor = debug_stats_num_fetches; break;
    case 2: fragColor = debug_stats_num_steps;   break;
}