
#if INTERPOLATION_METHOD == 0
#include "./intersected_trace/intersected_trace_trilinear"

#elif INTERPOLATION_METHOD == 1
#include "./intersected_trace/intersected_trace_tricubic"
#endif




