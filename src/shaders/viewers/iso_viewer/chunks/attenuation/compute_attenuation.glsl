// COMPUTE_ATTENUATION

// attenuation_smoothstep
#if ATTENUATION_METHOD == 1  
#include "./modules/attenuation_smoothstep"

// attenuation_physical
#elif ATTENUATION_METHOD == 2 
#include "./modules/attenuation_physical"

#else  
#error "unknown: ATTENUATION_METHOD"

#endif // ATTENUATION_METHOD
