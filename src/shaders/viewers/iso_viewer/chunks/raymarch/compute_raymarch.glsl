#ifndef HAS_SKIPPING
    #define HAS_SKIPPING 0
#endif

#if HAS_SKIPPING == 0  
    #include "./modules/raymarch_full"

#elif HAS_SKIPPING == 1
    #include "./modules/raymarch_skip"

#else  
    #error "unknown: HAS_SKIPPING"
#endif
