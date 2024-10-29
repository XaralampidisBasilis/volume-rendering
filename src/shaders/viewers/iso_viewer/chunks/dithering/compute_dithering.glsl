
// COMPUTE_DITHERING
/**
 * Includes the appropriate dithering module based on the `RAY_DITHERING_METHOD` macro,
 * provided that `RAY_DITHERING_ENABLED` is enabled.
 *
 * @macro RAY_DITHERING_ENABLED: Flag to enable or disable dithering (1 to enable)
 * @macro RAY_DITHERING_METHOD : The method used to compute dithering
 */

#if RAY_DITHERING_ENABLED == 1

    // dithering_generative
    #if RAY_DITHERING_METHOD == 1  
        #include "./modules/dithering_generative"  

    // dithering_texture
    #elif RAY_DITHERING_METHOD == 2
        #include "./modules/dithering_texture"  

    // unknown dithering method
    #else  
        #error "Unknown RAY_DITHERING_METHOD: Valid values are 1 or 2."

    #endif // RAY_DITHERING_METHOD

#endif // RAY_DITHERING_ENABLED
