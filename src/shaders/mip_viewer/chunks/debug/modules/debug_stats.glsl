
// COMPUTE DEBUG

// num fetches
vec4 debug_stats_num_fetches = to_color(float(stats.num_fetches) / float(MAX_NUM_FETCHES) * 2.0);

// num steps
vec4 debug_stats_num_steps = to_color(float(stats.num_steps) / float(MAX_CELL_COUNT));

// num skips
vec4 debug_stats_num_skips = to_color(float(stats.num_skips) / float(MAX_BLOCK_COUNT) * 2.0);


// PRINT DEBUG

switch (u_debugging.option - debug.slot_stats)
{
    case 1: fragColor = debug_stats_num_fetches; break;
    case 2: fragColor = debug_stats_num_steps;   break;
    case 3: fragColor = debug_stats_num_skips;   break;
}