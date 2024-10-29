
#if RAY_GRADIENTS_ENABLED == 1

    // gradient_tetrahedron_trilinear
    #if RAY_GRADIENTS_METHOD == 1
        #include "./modules/gradient_tetrahedron_trilinear"

    // gradient_central
    #elif RAY_GRADIENTS_METHOD == 2
        #include "./modules/gradient_central"

    // gradient_sobel
    #elif RAY_GRADIENTS_METHOD == 3
        #include "./modules/gradient_sobel_trilinear"

    // gradient_tetrahedron
    #elif RAY_GRADIENTS_METHOD == 4
        #include "./modules/gradient_tetrahedron"

    // gradient_prewitt
    #elif RAY_GRADIENTS_METHOD == 5
        #include "./modules/gradient_prewitt"

    // gradient_sobel
    #elif RAY_GRADIENTS_METHOD == 6
        #include "./modules/gradient_sobel"

    // gradient_scharr
    #elif RAY_GRADIENTS_METHOD == 7
        #include "./modules/gradient_scharr"

    #else  
        #error "unknown: RAY_GRADIENTS_METHOD"

    #endif // RAY_GRADIENTS_METHOD
    
#endif // RAY_GRADIENTS_ENABLED