
// smoothing_mean
#if SMOOTHING_METHOD == 1
    #include "./modules/smoothing_mean"
    
// smoothing_mean_trilinear
#elif SMOOTHING_METHOD == 2
    #include "./modules/smoothing_mean_trilinear"

// smoothing_gaussian
#elif SMOOTHING_METHOD == 3
    #include "./modules/smoothing_gaussian"

// smoothing_gaussian_trilinear
#elif SMOOTHING_METHOD == 4
    #include "./modules/smoothing_gaussian_trilinear"

// smoothing_bessel
#elif SMOOTHING_METHOD == 5
    #include "./modules/smoothing_bessel"

// smoothing_conservative
#elif SMOOTHING_METHOD == 6
    #include "./modules/smoothing_conservative"

// smoothing_default
#else  
    #include "./modules/smoothing_default"

#endif // SMOOTHING_METHOD
