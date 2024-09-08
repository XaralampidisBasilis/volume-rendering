#ifndef PARAMETERS_DEBUG
#define PARAMETERS_DEBUG

// Struct to hold information about a ray trace intersection in normalized coordinates
struct parameters_debug 
{
    int iterations;
};

void set_debug(inout parameters_debug debug)
{
    debug.iterations = 0;
}

#endif
