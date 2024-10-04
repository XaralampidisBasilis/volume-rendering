
// COMPUTE_STEPPING
/**
 * Includes the appropriate stepping module based on the `STEPPING_METHOD` macro.
 *
 * @macro STEPPING_METHOD : The method used to compute the stepping size
 */

// stepping_taylor_linear
#if STEPPING_METHOD == 1  
    #include "./modules/stepping_taylor_linear"   

// stepping_taylor_quadratic
#elif STEPPING_METHOD == 2  
    #include "./modules/stepping_taylor_quadratic"   

// stepping_taylor_cubic
#elif STEPPING_METHOD == 3  
    #include "./modules/stepping_taylor_cubic"  

// stepping_pade_rational11
#elif STEPPING_METHOD == 4
    #include "./modules/stepping_pade_rational11" 

// stepping_pade_rational02
#elif STEPPING_METHOD == 5
    #include "./modules/stepping_pade_rational02" 

// stepping_pade_rational21
#elif STEPPING_METHOD == 6
    #include "./modules/stepping_pade_rational21" 

// stepping_pade_rational12
#elif STEPPING_METHOD == 7
    #include "./modules/stepping_pade_rational12" 

// stepping_pade_rational03
#elif STEPPING_METHOD == 8
    #include "./modules/stepping_pade_rational03" 

// stepping_derivative
#elif STEPPING_METHOD == 9
    #include "./modules/stepping_derivative"

// stepping_normal
#elif STEPPING_METHOD == 10
    #include "./modules/stepping_normal"    

// stepping_gradient_norm
#elif STEPPING_METHOD == 11
    #include "./modules/stepping_gradient_norm" 

// stepping_uniform
#elif STEPPING_METHOD == 12
    #include "./modules/stepping_uniform"   

#else  
    #error "Unknown STEPPING_METHOD."

#endif // STEPPING_METHOD
