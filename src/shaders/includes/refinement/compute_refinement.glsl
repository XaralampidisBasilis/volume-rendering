#include "./refinement_uniform"
#include "./refinement_bisection"
#include "./refinement_adaptive"

void compute_refinement
(
    in uniforms_volume u_volume, 
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient,
    in uniforms_sampler u_sampler, 
    in parameters_ray ray,
    inout parameters_trace trace
) 
{
    switch(u_raycast.refinement_method)
    {
        case 1: 
            refinement_uniform(u_volume, u_raycast, u_gradient, u_sampler, ray, trace);
            return;
        case 2: 
            refinement_bisection(u_volume, u_raycast, u_gradient, u_sampler, ray, trace);
            return;
        case 3: 
            refinement_adaptive(u_volume, u_raycast, u_gradient, u_sampler, ray, trace);
            return;
    }
}