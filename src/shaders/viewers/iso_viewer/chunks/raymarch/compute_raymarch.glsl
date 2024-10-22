
#if HAS_SKIPPING == 0
    #include "./modules/raymarch_full"

#elif HAS_SKIPPING == 1
    #include "./modules/raymarch_skipping"

#else  
    #error "Unknown HAS_SKIPPING."

#endif // HAS_SKIPPING
