
// tapering_const
#if RAY_TAPERING_METHOD == 1  
    #include "./modules/tapering_const"

// tapering_log
#elif RAY_TAPERING_METHOD == 2
    #include "./modules/tapering_log"

// tapering_sqrt
#elif RAY_TAPERING_METHOD == 3
    #include "./modules/tapering_sqrt"

// tapering_linear
#elif RAY_TAPERING_METHOD == 4
    #include "./modules/tapering_linear"

// tapering_smoothstep
#elif RAY_TAPERING_METHOD == 5
    #include "./modules/tapering_smoothstep"

// tapering_exp
#elif RAY_TAPERING_METHOD == 6
    #include "./modules/tapering_exp"

// unknown tapering method
#else  
    #error "Unknown RAY_TAPERING_METHOD: Valid values are 1 to 6"

#endif // RAY_TAPERING_METHOD
