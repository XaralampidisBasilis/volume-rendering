// COMPUTE_SHADING

// shading_blinn
#if SHADING_METHOD == 1  
#include "./modules/shading_blinn"

// shading_phong
#elif SHADING_METHOD == 2 
#include "./modules/shading_phong"

#else  
#error "unknown: SHADING_METHOD"

#endif // SHADING_METHOD
