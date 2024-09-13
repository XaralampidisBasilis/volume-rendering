#ifndef HAS_DITHERING
#define HAS_DITHERING 1
#endif

#ifndef DITHERING_METHOD
#define DITHERING_METHOD 0
#endif

#if HAS_DITHERING == 1

    #if DITHERING_METHOD == 0  
        #include "./modules/dithering_generative"

    #elif DITHERING_METHOD == 1
        #include "./modules/dithering_texture"

    #else  
        #error "unknown: DITHERING_METHOD"
    #endif

#endif
