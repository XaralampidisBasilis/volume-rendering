#ifndef PARAMETERS_TRACE
#define PARAMETERS_TRACE

// Struct to hold information about a ray trace intersection in normalized coordinates
struct parameters_trace 
{
    vec3 position;   // Intersection position
    vec3 normal;     // Intersection normal
    float value;     // Scalar value at the intersection
    float depth;     // Distance the ray has traveled to the intersection
    float steepness; // The normalized length of the gradient vector
};

parameters_trace trace;

void set_trace(in vec3 position)
{
    trace.position = position;
    trace.normal = vec3(0.0); 
    trace.value = 0.0;    
    trace.depth = 0.0;
    trace.steepness = 0.0;    
}

#endif
