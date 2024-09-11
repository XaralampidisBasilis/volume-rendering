#ifndef PARAMETERS_DEBUG
#define PARAMETERS_DEBUG

// struct to hold gradient uniforms
struct parameters_debug 
{
    vec3 variable1;
    vec3 variable2;
    vec3 variable3;
    vec3 variable4;
    vec3 variable5;
};

void set_debug(inout parameters_debug debug)
{
    debug.variable1 = vec3(0.0);
    debug.variable2 = vec3(0.0);
    debug.variable3 = vec3(0.0);
    debug.variable4 = vec3(0.0);
    debug.variable5 = vec3(0.0);
}

#endif