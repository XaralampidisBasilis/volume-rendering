float max_value = max_trace.sample_value;

Trace trace_roots[2];
Trace trace_prev;
Trace trace_next;

for (int iter = 0; iter < 5; iter++)
{
    #include "./update_trace_next"
    #include "./update_trace_prev"
    #include "./update_max_trace"
}

debug.variable1 = vec4(vec3(max_trace.sample_value - max_value)/max_value, 1.0);