#ifndef PARAMETERS_DEBUG
#define PARAMETERS_DEBUG

// Struct to hold information about a ray trace intersection in normalized coordinates
struct parameters_debug 
{
    int iterations;
};

parameters_debug debug;

void set_debug()
{
    debug.iterations = 0;
}

#endif
