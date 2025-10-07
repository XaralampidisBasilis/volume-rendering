
#if INTERPOLATION_METHOD == 0
#include "./intersect_cell/intersect_cell_trilinear"

#elif INTERPOLATION_METHOD == 1
#include "./intersect_cell/intersect_cell_tricubic"
#endif

