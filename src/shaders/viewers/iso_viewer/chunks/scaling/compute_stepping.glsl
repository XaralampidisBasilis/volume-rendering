
// COMPUTE_STEPPING
/**
 * Includes the appropriate scaling module based on the `TRACE_SCALING_METHOD` macro.
 *
 * @macro TRACE_SCALING_METHOD : The method used to compute the scaling size
 */

// scaling_taylor_linear
#if TRACE_SCALING_METHOD == 1  
    #include "./modules/scaling_taylor_linear"   

// scaling_taylor_quadratic
#elif TRACE_SCALING_METHOD == 2  
    #include "./modules/scaling_taylor_quadratic"   

// scaling_taylor_cubic
#elif TRACE_SCALING_METHOD == 3  
    #include "./modules/scaling_taylor_cubic"  

// scaling_pade_rational11
#elif TRACE_SCALING_METHOD == 4
    #include "./modules/scaling_pade_rational11" 

// scaling_pade_rational02
#elif TRACE_SCALING_METHOD == 5
    #include "./modules/scaling_pade_rational02" 

// scaling_pade_rational21
#elif TRACE_SCALING_METHOD == 6
    #include "./modules/scaling_pade_rational21" 

// scaling_pade_rational12
#elif TRACE_SCALING_METHOD == 7
    #include "./modules/scaling_pade_rational12" 

// scaling_pade_rational03
#elif TRACE_SCALING_METHOD == 8
    #include "./modules/scaling_pade_rational03" 

// scaling_pade_rational22
#elif TRACE_SCALING_METHOD == 9
    #include "./modules/scaling_pade_rational22" 

// scaling_uniform
#elif TRACE_SCALING_METHOD == 10
    #include "./modules/scaling_uniform"   

#else  
    #error "Unknown TRACE_SCALING_METHOD."

#endif // TRACE_SCALING_METHOD
