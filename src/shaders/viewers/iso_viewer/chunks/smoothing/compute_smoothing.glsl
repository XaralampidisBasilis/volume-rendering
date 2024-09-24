
#if HAS_SMOOTHING_REFINEMENT == 1

    // smoothing_mean
    #if SMOOTHING_REFINEMENT_METHOD == 1
        #include "./modules/smoothing_mean"

    // smoothing_conservative
    #elif SMOOTHING_REFINEMENT_METHOD == 2
        #include "./modules/smoothing_conservative"

    // smoothing_gaussian
    #elif SMOOTHING_REFINEMENT_METHOD == 3
        #include "./modules/smoothing_gaussian"

    // smoothing_bessel
    #elif SMOOTHING_REFINEMENT_METHOD == 4
        #include "./modules/smoothing_bessel"

    // smoothing_trilinear
    #elif SMOOTHING_REFINEMENT_METHOD == 5
        #include "./modules/smoothing_trilinear"

    #else  
        #error "unknown: SMOOTHING_REFINEMENT_METHOD"

    #endif // SMOOTHING_REFINEMENT_METHOD
    
#endif // HAS_SMOOTHING_REFINEMENT