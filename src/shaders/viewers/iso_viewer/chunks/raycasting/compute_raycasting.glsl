
// setup occumap and ray
#include "./modules/setup_occumap"
#include "./modules/setup_ray"
#include "./modules/setup_trace"

#include "./modules/start_trace_prev"

// ray marching loop to traverse through the volume
#include "../marching/compute_marching"

if (ray.intersected) 
{
    #include "../refinement/compute_refinement"
    #include "../gradient/compute_gradient"
}

if (ray.terminated)
{
    #include "./modules/terminate_trace"
    #if RAY_DISCARDING_DISABLED == 0
    discard;  
    #endif
}




