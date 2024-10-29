

// { has_gradient_refinement : 0, 1}
#ifndef RAY_GRADIENTS_ENABLED
#define RAY_GRADIENTS_ENABLED 1
#endif

// {tetrahedron_trilinear: 1, central: 2, sobel_trilinear: 3, tetrahedron: 4, prewitt: 5, sobel: 6, scharr: 7 }
#ifndef RAY_GRADIENTS_METHOD
#define RAY_GRADIENTS_METHOD 3 
#endif

// {hermite_cubic, hermite_rational21, hermite_rational12}
#ifndef TRACE_DERIVATIVES_METHOD
#define TRACE_DERIVATIVES_METHOD 1 
#endif