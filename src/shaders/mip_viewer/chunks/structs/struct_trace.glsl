#ifndef STRUCT_TRACE
#define STRUCT_TRACE

// struct to hold information about the current ray trace 
struct Trace 
{
    bool  intersected;          // flag indicating if the trace intersected with the u_intensity_map
    bool  terminated;           // flag indicating if the trace has reached out of u_intensity_map bounds
    bool  exhausted;            // flag indicating if the trace has reached the max step count

    ivec3 coords;
    vec3  position;             // current position in 3d model coordinates
    vec3  uvw;                  // current position in 3d model coordinates
    float distance;             // current distance traveled from camera

    vec3  gradient;             // gradient vector
    float intensity;            // sampled value at the current position
    float error;           
};

Trace set_trace()
{
    Trace trace;
    trace.intersected      = false;
    trace.terminated       = false;
    trace.exhausted        = false;
    trace.coords           = ivec3(0.0);
    trace.position         = vec3(0.0);
    trace.uvw              = vec3(0.0);
    trace.distance         = 0.0;
    trace.gradient         = vec3(0.0);
    trace.intensity        = 0.0;
    trace.error            = 0.0;
    return trace;
}
void discard_trace(inout Trace trace)
{
    trace.position           = vec3(0.0);
    trace.distance           = 0.0;
    trace.error              = 0.0;
}

#endif // STRUCT_TRACE
