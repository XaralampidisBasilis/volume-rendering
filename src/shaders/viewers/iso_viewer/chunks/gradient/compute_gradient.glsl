
// gradient_tetrahedron4
#if GRADIENT_METHOD == 1
#include "./modules/gradient_tetrahedron4"

// gradient_central6
#elif GRADIENT_METHOD == 2
#include "./modules/gradient_central6"

// gradient_sobel8
#elif GRADIENT_METHOD == 3
#include "./modules/gradient_sobel8"

// gradient_tetrahedron27
#elif GRADIENT_METHOD == 4
#include "./modules/gradient_tetrahedron27"

// gradient_prewitt27
#elif GRADIENT_METHOD == 5
#include "./modules/gradient_prewitt27"

// gradient_sobel27
#elif GRADIENT_METHOD == 6
#include "./modules/gradient_sobel27"

// gradient_scharr27
#elif GRADIENT_METHOD == 7
#include "./modules/gradient_scharr27"

#else  
#error "unknown: GRADIENT_METHOD"

#endif // GRADIENT_METHOD
