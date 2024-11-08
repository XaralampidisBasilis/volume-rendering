#include "./modules/compute_trace_states"

if (trace.intersected) 
{
    #include "./modules/compute_trace_position_refinement"
    #include "./modules/compute_trace_gradient_refinement"
}

if (trace.terminated || trace.suspended)
{
    discard;  
}

