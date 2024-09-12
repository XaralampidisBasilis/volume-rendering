#include "./modules/refinement_sampling5"
#include "./modules/refinement_bisections5"
#include "./modules/refinement_newtons5"
#include "./modules/refinement_linear2"
#include "./modules/refinement_lagrange3"
#include "./modules/refinement_lagrange4"
#include "./modules/refinement_hermitian2"

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
    if (u_raycast.has_refinement)
    {
        switch(u_raycast.refinement_method)
        {
            case 1: 
                refinement_sampling5(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
            case 2: 
                refinement_bisections5(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
            case 3: 
                refinement_newtons5(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
            case 4: 
                refinement_linear2(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
            case 5: 
                refinement_lagrange3(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
            case 6: 
                refinement_lagrange4(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
            case 7:
                refinement_hermitian2(u_volume, u_raycast, u_gradient, u_sampler, ray, trace, prev_trace);
                return;
        }
    }
    
}