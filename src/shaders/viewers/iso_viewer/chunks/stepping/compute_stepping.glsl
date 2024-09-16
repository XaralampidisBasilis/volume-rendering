
// stepping_taylor1
#if STEPPING_METHOD == 1  
#include "./modules/stepping_taylor1"

// stepping_taylor2
#elif STEPPING_METHOD == 2  
#include "./modules/stepping_taylor2"

// stepping_gradial
#elif STEPPING_METHOD == 3
#include "./modules/stepping_gradial"

// stepping_alignment
#elif STEPPING_METHOD == 4
#include "./modules/stepping_alignment"

// stepping_steepness
#elif STEPPING_METHOD == 5
#include "./modules/stepping_steepness"

// stepping_uniform
#elif STEPPING_METHOD == 6
#include "./modules/stepping_uniform"

#else  
#error "unknown: STEPPING_METHOD"

#endif // STEPPING_METHOD