

// { has_gradient_refinement : 0, 1}
#ifndef HAS_GRADIENT_REFINEMENT
#define HAS_GRADIENT_REFINEMENT 1
#endif

// { tetrahedron4: 1, central6: 2, sobel8: 3, tetrahedron27: 4, prewitt27: 5, sobel27: 6, scharr27: 7 }
#ifndef GRADIENT_METHOD
#define GRADIENT_METHOD 3 
#endif

// { tetrahedron4: 1, central6: 2, sobel8: 3, tetrahedron27: 4, prewitt27: 5, sobel27: 6, scharr27: 7 }
#ifndef GRADIENT_REFINEMENT_METHOD
#define GRADIENT_REFINEMENT_METHOD 3 
#endif
