#ifndef STRUCT_TRACE
#define STRUCT_TRACE

struct Trace 
{
    bool  intersected;
    bool  terminated;           // flag indicating if the trace has reached out of u_intensity_map bounds
    bool  exhausted;
    ivec3 coords;
    vec3  position;             // current position in 3d model coordinates
    vec3  uvw;                  // current position in 3d model coordinates
    float distance;             // current distance traveled from camera
    float spacing;
    vec3  gradient;             // gradient vector
    float intensity;            // sampled value at the current position
};

Trace set_trace()
{
    Trace trace;
    trace.intersected = false;
    trace.terminated  = false;
    trace.exhausted   = false;
    trace.coords      = ivec3(0.0);
    trace.position    = vec3(0.0);
    trace.uvw         = vec3(0.0);
    trace.distance    = 0.0;
    trace.spacing     = 0.0;
    trace.gradient    = vec3(0.0);
    trace.intensity   = 0.0;
    return trace;
}

#endif // STRUCT_TRACE
