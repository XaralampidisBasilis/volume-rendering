
// setup occumap and ray
#include "./modules/setup_occumap"
#include "./modules/setup_ray"

// skip volume empty space 
#include "../skipping/compute_skipping"

// compute the ray step distance
#include "../stepping/compute_stepping"

// apply dithering step to avoid artifacts.
#include "../dithering/compute_dithering"

// setup trace after changes
#include "./modules/setup_trace"

// raycasting loop to traverse through the volume and find intersections.
#include "../raymarch/compute_raymarch"

// apply last refinements 
#include "../refinement/compute_refinement"
#include "../gradient/compute_gradient"



