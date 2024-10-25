
// COMPUTE_RAY_STEP_DISTANCE
/**
 * Selects the ray steping method based on the predefined RAYMARCH_STEPPING_METHOD.
 *  
 * @macro RAYMARCH_STEPPING_METHOD  : The method used to compute the ray step distance 
 */

// spacing_isotropic
#if RAYMARCH_STEPPING_METHOD == 1  
    #include "./modules/spacing_isotropic"

// spacing_directional
#elif RAYMARCH_STEPPING_METHOD == 2
    #include "./modules/spacing_directional"

// spacing_equalized
#elif RAYMARCH_STEPPING_METHOD == 3
    #include "./modules/spacing_equalized"

// unknown spacing method
#else  
    #error "Unknown RAYMARCH_STEPPING_METHOD: Valid values are 1 to 3"

#endif // RAYMARCH_STEPPING_METHOD
