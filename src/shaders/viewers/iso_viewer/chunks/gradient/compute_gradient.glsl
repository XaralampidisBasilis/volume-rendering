
// gradient_tetrahedron4
#if GRADIENT_METHOD == 1
#include "./modules/gradient_tetrahedron4"

// gradient_central6
#elif GRADIENT_METHOD == 2
#include "./modules/gradient_central6"

// gradient_sobel8
#elif GRADIENT_METHOD == 2
#include "./modules/gradient_sobel8"

// gradient_prewitt27
#elif GRADIENT_METHOD == 3
#include "./modules/gradient_prewitt27"

// gradient_sobel27
#elif GRADIENT_METHOD == 2
#include "./modules/gradient_sobel27"

// gradient_scharr27
#elif GRADIENT_METHOD == 4
#include "./modules/gradient_scharr27"

#else  
#error "unknown: GRADIENT_METHOD"

#endif // GRADIENT_METHOD
