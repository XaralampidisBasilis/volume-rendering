
// raymarch_full
#if HAS_SKIPPING == 0  
    #include "./modules/raymarch_full"

// raymarch_skip
#elif HAS_SKIPPING == 1
    #include "./modules/raymarch_skipping"

#else  
    #error "unknown: HAS_SKIPPING"

#endif // HAS_SKIPPING
