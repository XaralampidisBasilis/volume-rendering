
// COMPUTE_RAY_STEP
/**
 * Selects the ray steping method based on the predefined RAY_STEPPING_METHOD.
 *  
 * @macro RAY_STEPPING_METHOD  : The method used to compute the ray step distance 
 */

// stepping_isotropic
#if RAY_STEPPING_METHOD == 1  
    #include "./modules/stepping_isotropic"

// stepping_directional
#elif RAY_STEPPING_METHOD == 2
    #include "./modules/stepping_directional"

// stepping_equalized
#elif RAY_STEPPING_METHOD == 3
    #include "./modules/stepping_equalized"

// unknown stepping method
#else  
    #error "Unknown RAY_STEPPING_METHOD: Valid values are 1 to 3"

#endif // RAY_STEPPING_METHOD
