
// { has_dithering : 0, 1}
#ifndef HAS_DITHERING
#define HAS_DITHERING 1
#endif

// { has_refinement : 0, 1}
#ifndef HAS_REFINEMENT
#define HAS_REFINEMENT 1
#endif

// { has_skipping : 0, 1}
#ifndef HAS_SKIPPING
#define HAS_SKIPPING 0
#endif

// { generative: 1, texture: 2, }
#ifndef DITHERING_METHOD
#define DITHERING_METHOD 1
#endif

// { isotropic: 1, directional: 2, equalized: 3 }
#ifndef SPACING_METHOD
#define SPACING_METHOD 2
#endif

// { taylor1: 1, taylor2: 2, derivative: 3, normal: 4, gradient_norm: 5, uniform: 6 }
#ifndef TRACE_SCALING_METHOD
#define TRACE_SCALING_METHOD 1
#endif

// { sub_sampling: 1, bisection_iterative: 2, newtons_iterative: 3, linear: 4, lagrange_quadratic: 5, lagrange_cubic: 6, hermite_cubic: 7 }
#ifndef REFINEMENT_METHOD
#define REFINEMENT_METHOD 7 
#endif