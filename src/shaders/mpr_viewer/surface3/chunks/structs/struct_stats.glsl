#ifndef STRUCT_STATS
#define STRUCT_STATS

struct Stats
{
    int num_fetches;  // texture fetch
    int num_steps;
};

Stats set_stats()
{
    Stats stats;
    stats.num_fetches = 0;
    stats.num_steps   = 0;
    return stats;
}

#endif // STRUCT_STATS