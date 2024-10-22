
#if HAS_SKIPPING == 0
    #include "./raymarch_full"

#elif HAS_SKIPPING == 1
    #include "./raymarch_skipping"

#else  
    #error "Unknown HAS_SKIPPING."

#endif // HAS_SKIPPING
