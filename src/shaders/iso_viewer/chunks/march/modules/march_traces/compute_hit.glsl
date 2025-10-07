
#if INTERPOLATION_METHOD == 0
#include "./compute_hit/compute_hit_trilinear"

#elif INTERPOLATION_METHOD == 1
#include "./compute_hit/compute_hit_tricubic"
#endif

