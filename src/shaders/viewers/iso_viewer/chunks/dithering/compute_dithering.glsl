
// COMPUTE_DITHERING
/**
 * Includes the appropriate dithering module based on the `DITHERING_METHOD` macro,
 * provided that `HAS_DITHERING` is enabled.
 *
 * @macro HAS_DITHERING     : Flag to enable or disable dithering (1 to enable)
 * @macro DITHERING_METHOD  : The method used to compute dithering
 */

#if HAS_DITHERING == 1

    // dithering_generative
    #if DITHERING_METHOD == 1  
        #include "./modules/dithering_generative"    // Dithering based on random generation

    // dithering_texture
    #elif DITHERING_METHOD == 2
        #include "./modules/dithering_texture"       // Dithering based on a noise texture

    // unknown dithering method
    #else  
        #error "Unknown DITHERING_METHOD: Valid values are 1 or 2."

    #endif // DITHERING_METHOD

#endif // HAS_DITHERING
