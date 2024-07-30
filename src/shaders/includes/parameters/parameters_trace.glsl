#ifndef PARAMETERS_TRACE
#define PARAMETERS_TRACE

// Struct to hold information about a ray trace intersection
struct parameters_trace 
{
    vec3 position;   // Intersection position
    vec3 normal;     // Intersection normal
    vec3 gradient;   // Intersection gradient vector
    float value;     // Scalar value at the intersection
    float distance;  // Distance the ray has traveled to the intersection
    float slope;     // The length of the gradient vector
};

parameters_trace trace;

void set_trace(in vec3 position)
{
    trace.position = position;
    trace.normal = vec3(0.0); 
    trace.gradient = vec3(0.0); 
    trace.value = 0.0;    
    trace.distance = 0.0;
    trace.slope = 0.0;    
}

#endif
