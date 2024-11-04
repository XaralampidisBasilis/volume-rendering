
// setup occumap and ray
#include "./modules/setup_occumap"
#include "./modules/setup_ray"
#include "./modules/setup_trace"

// skip volume empty space 
#include "../skipping/compute_skipping"

// compute step tapering baced on ray start distance
#include "../tapering/compute_tapering"

// compute the ray step distance
#include "../stepping/compute_stepping"

// apply dithering step to avoid artifacts.
#include "../dithering/compute_dithering"

// ray marching loop to traverse through the volume
#include "../marching/compute_marching"

// apply last refinements 
#include "../refinement/compute_refinement"
#include "../gradient/compute_gradient"
// #include "../smoothing/compute_smoothing"



