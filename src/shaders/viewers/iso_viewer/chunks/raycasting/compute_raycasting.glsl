
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

// start structs before marching
#include "./modules/start_occumap"
#include "./modules/start_ray"
#include "./modules/start_trace_prev"

// ray marching loop to traverse through the volume
#include "../marching/compute_marching"

if (ray.intersected) 
{
    #include "../refinement/compute_refinement"
    #include "../gradient/compute_gradient"
    // #include "../smoothing/compute_smoothing"
}
else
{
    #include "./modules/terminate_trace"
    #if RAY_DISCARDING_DISABLED == 0
    discard;  
    #endif
}




