
// COMPUTE_DITHERING
/**
 * Includes the appropriate dithering module based on the `RAY_DITHERING_METHOD` macro,
 * provided that `RAY_DITHERING_ENABLED` is enabled.
 *
 * @macro RAY_DITHERING_ENABLED: Flag to enable or disable dithering (1 to enable)
 * @macro RAY_DITHERING_METHOD : The method used to compute dithering
 */

#if RAY_DITHERING_ENABLED == 1
#include "./dithering_generative"  
#endif // RAY_DITHERING_ENABLED
