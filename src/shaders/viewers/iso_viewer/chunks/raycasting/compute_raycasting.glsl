
// setup occumap and ray
#include "./modules/setup_occumap"
#include "./modules/setup_ray"
#include "./modules/setup_trace"

// skip volume empty space 
#include "../skipping/compute_skipping"

// compute the ray step distance
#include "../stepping/compute_stepping"

// apply dithering step to avoid artifacts.
#include "../dithering/compute_dithering"

// raycasting loop to traverse through the volume and find intersections.
#include "../raymarch/compute_raymarch"

// apply last refinements 
#include "../refinement/compute_refinement"
#include "../gradient/compute_gradient"
// #include "../smoothing/compute_smoothing"



