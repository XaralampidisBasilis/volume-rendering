// COMPUTE_ATTENUATION

#if LIGHTING_ATTENUATION_ENABLED == 1

    // attenuation_smoothstep
    #if LIGHTING_ATTENUATION_METHOD == 1  
        #include "./modules/attenuation_smoothstep"

    // attenuation_physical
    #elif LIGHTING_ATTENUATION_METHOD == 2 
        #include "./modules/attenuation_physical"

    #else  
        #error "unknown: LIGHTING_ATTENUATION_METHOD"

    #endif // LIGHTING_ATTENUATION_METHOD

#else
    float attenuation = 1.0;

#endif // LIGHTING_ATTENUATION_ENABLED
