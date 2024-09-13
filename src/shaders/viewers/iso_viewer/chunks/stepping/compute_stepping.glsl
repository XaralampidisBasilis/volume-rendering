

#if STEPPING_METHOD == 1  
#include "./modules/stepping_adaptive"

#elif STEPPING_METHOD == 2
#include "./modules/stepping_gradial"

#elif STEPPING_METHOD == 3
#include "./modules/stepping_alignment"

#elif STEPPING_METHOD == 4
#include "./modules/stepping_steepness"

#elif STEPPING_METHOD == 5
#include "./modules/stepping_uniform"

#else  
#error "unknown: STEPPING_METHOD"

#endif // STEPPING_METHOD