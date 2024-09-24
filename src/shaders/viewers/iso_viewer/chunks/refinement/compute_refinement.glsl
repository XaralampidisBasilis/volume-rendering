
#if HAS_REFINEMENT == 1

    // refinement_sampling5
    #if REFINEMENT_METHOD == 1  
        #include "./modules/refinement_sampling5"

    // refinement_bisections5
    #elif REFINEMENT_METHOD == 2
        #include "./modules/refinement_bisections5"

    // refinement_newtons5
    #elif REFINEMENT_METHOD == 3
        #include "./modules/refinement_newtons5"

    // refinement_linear2
    #elif REFINEMENT_METHOD == 4
        #include "./modules/refinement_linear2"

    // refinement_lagrange3
    #elif REFINEMENT_METHOD == 5
        #include "./modules/refinement_lagrange3"

    // refinement_lagrange4
    #elif REFINEMENT_METHOD == 6
        #include "./modules/refinement_lagrange4"

    // refinement_hermitian2
    #elif REFINEMENT_METHOD == 7
        #include "./modules/refinement_hermitian2"

    #else  
        #error "unknown: REFINEMENT_METHOD"

    #endif // REFINEMENT_METHOD
    
#endif // HAS_REFINEMENT