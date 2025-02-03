
// COMPUTE DEBUG

// num fetches
float debug_stats_num_fetches = float(stats.num_fetches) / float(MAX_NUM_FETCHES);
debug.stats_num_fetches = vec4(vec3(debug_stats_num_fetches * 2.0), 1.0);

// num steps
float debug_stats_num_steps = float(stats.num_steps) / float(MAX_NUM_STEPS);
debug.stats_num_steps = vec4(vec3(debug_stats_num_steps), 1.0);

// num skips
float debug_stats_num_skips = float(stats.num_skips) / float(MAX_NUM_SKIPS);
debug.stats_num_skips = vec4(vec3(debug_stats_num_skips * 2.0), 1.0);


// PRINT DEBUG

switch (u_debugging.option - debug.slot_stats)
{
    case 1: fragColor = debug.stats_num_fetches; break;
    case 2: fragColor = debug.stats_num_steps;   break;
    case 3: fragColor = debug.stats_num_skips;   break;
}