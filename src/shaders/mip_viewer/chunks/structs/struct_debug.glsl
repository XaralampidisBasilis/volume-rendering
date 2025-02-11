#ifndef STRUCT_DEBUG
#define STRUCT_DEBUG

struct Debug 
{
    vec4 variable1;
    vec4 variable2;
    vec4 variable3;
};

Debug set_debug()
{
    Debug debug;

    debug.variable1 = to_color(0.0);
    debug.variable2 = to_color(0.0);
    debug.variable3 = to_color(0.0);

    return debug;
}

#endif // STRUCT_DEBUG