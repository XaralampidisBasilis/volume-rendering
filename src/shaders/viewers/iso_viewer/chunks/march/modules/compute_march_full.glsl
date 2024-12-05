#include "./start_trace"

for (trace.step_count = 0; trace.step_count < MAX_TRACE_STEP_COUNT; trace.step_count++) 
{
    #include "./update_trace" 
    if (!trace.update) break;
}   

#include "./end_trace"