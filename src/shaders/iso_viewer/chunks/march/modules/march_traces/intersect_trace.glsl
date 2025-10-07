
#if INTERPOLATION_METHOD == 0
#include "./intersect_trace/intersect_trace_trilinear"

#elif INTERPOLATION_METHOD == 1
#include "./intersect_trace/intersect_trace_tricubic"
#endif
