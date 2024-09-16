
// COMPUTE_STEPPING
/**
 * Includes the appropriate stepping module based on the `STEPPING_METHOD` macro.
 *
 * @macro STEPPING_METHOD : The method used to compute the stepping size
 */

#if STEPPING_METHOD == 1  
    #include "./modules/stepping_taylor1"    // Taylor-based stepping (first-order)

#elif STEPPING_METHOD == 2  
    #include "./modules/stepping_taylor2"    // Taylor-based stepping (second-order)

#elif STEPPING_METHOD == 3
    #include "./modules/stepping_derivative" // Stepping based on trace derivatives

#elif STEPPING_METHOD == 4
    #include "./modules/stepping_normal"     // Stepping based on trace normal alignment

#elif STEPPING_METHOD == 5
    #include "./modules/stepping_gradient_norm" // Stepping based on trace gradient norm

#elif STEPPING_METHOD == 6
    #include "./modules/stepping_uniform"    // Uniform stepping

#else  
    #error "Unknown STEPPING_METHOD: Valid values are 1 to 6."

#endif // STEPPING_METHOD
