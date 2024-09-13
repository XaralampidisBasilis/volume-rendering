#ifndef HAS_REFINEMENT
    #define HAS_REFINEMENT 1
#endif

#ifndef REFINEMENT_METHOD
    #define REFINEMENT_METHOD 2
#endif

#if HAS_REFINEMENT == 1

    #if REFINEMENT_METHOD == 1  
        #include "./modules/refinement_sampling5"

    #elif REFINEMENT_METHOD == 2
        #include "./modules/refinement_bisections5"

    #elif REFINEMENT_METHOD == 3
        #include "./modules/refinement_newtons5"

    #elif REFINEMENT_METHOD == 4
        #include "./modules/refinement_linear2"

    #elif REFINEMENT_METHOD == 5
        #include "./modules/refinement_lagrange3"

    #elif REFINEMENT_METHOD == 6
        #include "./modules/refinement_lagrange4"

    #elif REFINEMENT_METHOD == 7
        #include "./modules/refinement_hermitian2"

    #else  
        #error "unknown: REFINEMENT_METHOD"
    #endif

#endif