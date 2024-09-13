
#include "./modules/stepping_adaptive"
#include "./modules/stepping_gradial"
#include "./modules/stepping_alignment"
#include "./modules/stepping_steepness"
#include "./modules/stepping_uniform"

#ifndef STEPPING_METHOD
    #error "undefined: STEPPING_METHOD"
#else
#if STEPPING_METHOD > 5
    #error "unknown: STEPPING_METHOD"
#endif
#endif