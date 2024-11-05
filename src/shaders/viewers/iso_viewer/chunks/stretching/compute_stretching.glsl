
// stretching_const
#if RAY_STRETCHING_METHOD == 1  
    #include "./modules/stretching_const"

// stretching_log
#elif RAY_STRETCHING_METHOD == 2
    #include "./modules/stretching_log"

// stretching_sqrt
#elif RAY_STRETCHING_METHOD == 3
    #include "./modules/stretching_sqrt"

// stretching_linear
#elif RAY_STRETCHING_METHOD == 4
    #include "./modules/stretching_linear"

// stretching_smoothstep
#elif RAY_STRETCHING_METHOD == 5
    #include "./modules/stretching_smoothstep"

// stretching_exp
#elif RAY_STRETCHING_METHOD == 6
    #include "./modules/stretching_exp"

// unknown stretching method
#else  
    #error "Unknown RAY_STRETCHING_METHOD: Valid values are 1 to 6"

#endif // RAY_STRETCHING_METHOD
