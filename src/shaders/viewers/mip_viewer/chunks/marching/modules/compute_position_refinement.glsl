float max_value = max_trace.sample_value;

if (int(u_debugger.variable4) == 1)
{
    #include "./compute_position_refinement_1"
}

if (int(u_debugger.variable4) == 2)
{
    #include "./compute_position_refinement_2"
}

if (int(u_debugger.variable4) == 3)
{
    #include "./compute_position_refinement_3"
}

debug.variable1 = vec4(vec3(max_trace.sample_value - max_value)/0.1, 1.0);