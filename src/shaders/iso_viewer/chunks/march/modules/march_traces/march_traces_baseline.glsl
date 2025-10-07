
trace.spacing = ray.spacing / 5.0;
#include "./start_trace"

for (int i = 0; i < MAX_TRACES; i++) 
{
    #include "./update_trace"
    #include "./intersected_trace"
    if (trace.intersected || trace.terminated) break;
}

#include "./end_trace"
