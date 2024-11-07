#if TRACE_BVH_MARCHING_ENABLED == 1
#include "./compute_trace_bvh_marching"
#else
#include "./compute_trace_full_marching"
#endif
