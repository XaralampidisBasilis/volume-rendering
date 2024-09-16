
// COMPUTE_SPACING
/**
 * Selects the ray spacing method based on the predefined SPACING_METHOD.
 *  
 * @macro SPACING_METHOD  : The method used to compute spacing
 */

// spacing_isotropic
#if SPACING_METHOD == 1  
    #include "./modules/spacing_isotropic"

// spacing_directional
#elif SPACING_METHOD == 2
    #include "./modules/spacing_directional"

// spacing_equalized
#elif SPACING_METHOD == 3
    #include "./modules/spacing_equalized"

// unknown spacing method
#else  
    #error "Unknown DITHERING_METHOD: Valid values are 1 to 3"

#endif // SPACING_METHOD
