
// gradient_tetrahedron_trilinear
#if GRADIENT_METHOD == 1
    #include "./modules/gradient_tetrahedron_trilinear"

// gradient_central
#elif GRADIENT_METHOD == 2
    #include "./modules/gradient_central"

// gradient_sobel_trilinear
#elif GRADIENT_METHOD == 3
    #include "./modules/gradient_sobel_trilinear"

// gradient_tetrahedron
#elif GRADIENT_METHOD == 4
    #include "./modules/gradient_tetrahedron"

// gradient_prewitt
#elif GRADIENT_METHOD == 5
    #include "./modules/gradient_prewitt"

// gradient_sobel
#elif GRADIENT_METHOD == 6
    #include "./modules/gradient_sobel"

// gradient_scharr
#elif GRADIENT_METHOD == 7
    #include "./modules/gradient_scharr"

#else  
    #error "unknown: GRADIENT_METHOD"

#endif // GRADIENT_METHOD

