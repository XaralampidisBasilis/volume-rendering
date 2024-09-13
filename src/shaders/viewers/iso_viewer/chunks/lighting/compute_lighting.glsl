
#ifndef LIGHTING_METHOD
#define LIGHTING_METHOD 0
#endif

#if LIGHTING_METHOD == 0  
    #include "./modules/lighting_blinn"

#elif LIGHTING_METHOD == 1
    #include "./modules/lighting_phong"

#else  
    #error "unknown: LIGHTING_METHOD"
#endif
