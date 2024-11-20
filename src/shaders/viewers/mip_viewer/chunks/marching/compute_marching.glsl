#if TRACE_BVH_MARCHING_ENABLED == 1
#include "./modules/compute_extremap_marching/compute_extremap_marching"
#else
#include "./compute_full_marching"
#endif
