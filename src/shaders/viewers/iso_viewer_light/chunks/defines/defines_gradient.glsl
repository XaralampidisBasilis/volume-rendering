

// { has_gradient_refinement : 0, 1}
#ifndef HAS_GRADIENT_REFINEMENT
#define HAS_GRADIENT_REFINEMENT 1
#endif

// {tetrahedron_trilinear: 1, central: 2, sobel_trilinear: 3, tetrahedron: 4, prewitt: 5, sobel: 6, scharr: 7 }
#ifndef GRADIENT_METHOD
#define GRADIENT_METHOD 3 
#endif

// {tetrahedron_trilinear: 1, central: 2, sobel_trilinear: 3, tetrahedron: 4, prewitt: 5, sobel: 6, scharr: 7 }
#ifndef GRADIENT_REFINEMENT_METHOD
#define GRADIENT_REFINEMENT_METHOD 3 
#endif

// {hermite_cubic, hermite_rational21, hermite_rational12}
#ifndef DERIVATIVE_METHOD
#define DERIVATIVE_METHOD 1 
#endif