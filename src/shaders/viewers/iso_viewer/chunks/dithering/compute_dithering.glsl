
#if HAS_DITHERING == 1

// dithering_generative
#if DITHERING_METHOD == 1  
#include "./modules/dithering_generative"

// dithering_texture
#elif DITHERING_METHOD == 2
#include "./modules/dithering_texture"

#else  
#error "unknown: DITHERING_METHOD"

#endif // DITHERING_METHOD
#endif // HAS_DITHERING
