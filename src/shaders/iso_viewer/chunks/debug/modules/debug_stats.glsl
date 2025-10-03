
// COMPUTE DEBUG

// num fetches
vec4 debug_stats_num_fetches = to_color(float(stats.num_fetches) / float(MAX_CELLS) * 10.0);

// num steps
vec4 debug_stats_num_cells = to_color(float(stats.num_cells) / float(MAX_CELLS) * 10.0);

// num skips
vec4 debug_stats_num_blocks = to_color(float(stats.num_blocks) / float(MAX_BLOCKS) * 10.0);

// num checks
vec4 debug_stats_num_tests = to_color(float(stats.num_tests) / float(MAX_BLOCKS) * 100.0);

// PRINT DEBUG

switch (u_debug.option - 900)
{
    case 1: fragColor = debug_stats_num_fetches; break;
    case 2: fragColor = debug_stats_num_cells;   break;
    case 3: fragColor = debug_stats_num_blocks;  break;
    case 4: fragColor = debug_stats_num_tests;  break;
}