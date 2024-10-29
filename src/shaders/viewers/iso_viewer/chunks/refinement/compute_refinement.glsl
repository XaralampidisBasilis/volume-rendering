
#if RAY_REFINEMENT_ENABLED == 1

    // refinement_sub_sampling
    #if RAY_REFINEMENT_METHOD == 1  
        #include "./modules/refinement_sub_sampling"

    // refinement_bisection_iterative
    #elif RAY_REFINEMENT_METHOD == 2
        #include "./modules/refinement_bisection_iterative"

    // refinement_newton_iterative
    #elif RAY_REFINEMENT_METHOD == 3
        #include "./modules/refinement_newton_iterative"

    // refinement_linear
    #elif RAY_REFINEMENT_METHOD == 4
        #include "./modules/refinement_linear"

    // refinement_lagrange_quadratic
    #elif RAY_REFINEMENT_METHOD == 5
        #include "./modules/refinement_lagrange_quadratic"

    // refinement_lagrange_cubic
    #elif RAY_REFINEMENT_METHOD == 6
        #include "./modules/refinement_lagrange_cubic"

    // refinement_hermite_cubic
    #elif RAY_REFINEMENT_METHOD == 7
        #include "./modules/refinement_hermite_cubic"

    #else  
        #error "unknown: RAY_REFINEMENT_METHOD"

    #endif // RAY_REFINEMENT_METHOD
    
#endif // RAY_REFINEMENT_ENABLED