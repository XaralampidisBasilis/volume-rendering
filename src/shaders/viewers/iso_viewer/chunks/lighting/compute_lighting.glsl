
// lighting_blinn
#if LIGHTING_METHOD == 1  
#include "./modules/lighting_blinn"

// lighting_phong
#elif LIGHTING_METHOD == 2 
#include "./modules/lighting_phong"

#else  
#error "unknown: LIGHTING_METHOD"

#endif // LIGHTING_METHOD
