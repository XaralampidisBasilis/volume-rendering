#include "./refinement_sampling"
#include "./refinement_bisection"
#include "./refinement_linear"
#include "./refinement_lagrange"
#include "./refinement_hermitian"

void compute_refinement
(
    in uniforms_volume u_volume, 
    in uniforms_raycast u_raycast, 
    in uniforms_gradient u_gradient,
    in uniforms_sampler u_sampler, 
    in parameters_ray ray,
    inout parameters_trace trace,
    inout parameters_trace prev_trace
) 
{
    switch(u_raycast.refinement_method)
    {
        case 1: 
            refinement_sampling(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
            return;
        case 2: 
            refinement_bisection(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
            return;
        case 3: 
            refinement_linear(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
            return;
        case 4: 
            refinement_lagrange(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
            return;
        case 5:
            refinement_hermitian(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
            return;
    }
}