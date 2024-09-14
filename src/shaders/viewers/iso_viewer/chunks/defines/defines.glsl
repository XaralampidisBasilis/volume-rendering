// { has_dithering : 0, 1}
#ifndef HAS_DITHERING
#define HAS_DITHERING 1
#endif

// { has_refinement : 0, 1}
#ifndef HAS_REFINEMENT
#define HAS_REFINEMENT 1
#endif

// { has_bbox : 0, 1}
#ifndef HAS_BBOX
#define HAS_BBOX 1
#endif

// { has_skipping : 0, 1}
#ifndef HAS_SKIPPING
#define HAS_SKIPPING 0
#endif

// { sobel8: 1, sobel27: 2, scharr27: 3, prewitt27: 4, central6: 5, tetrahedron4: 6 }
#ifndef GRADIENT_METHOD
#define GRADIENT_METHOD 1 
#endif

// { generative: 1, texture: 2, }
#ifndef DITHERING_METHOD
#define DITHERING_METHOD 1
#endif

// { isotropic: 1, directional: 2, traversal: 3 }
#ifndef SPACING_METHOD
#define SPACING_METHOD 2
#endif

// { adaptive: 1, gradial: 2, alignment: 3, steepness: 4, uniform: 5 }
#ifndef STEPPING_METHOD
#define STEPPING_METHOD 1
#endif

// { sampling5: 1, bisections5: 2, newtons5: 3, linear2: 4, lagrange3: 5, lagrange4: 6, hermitian2: 7 }
#ifndef REFINEMENT_METHOD
#define REFINEMENT_METHOD 7 
#endif

// { blinn: 1, phong: 2}
#ifndef LIGHTING_METHOD
#define LIGHTING_METHOD 1
#endif

