#ifndef STRUCT_TRACE
#define STRUCT_TRACE

// struct to hold information about the current ray trace 
struct Trace 
{
    bool  intersected;          // flag indicating if the trace intersected with the u_volume
    bool  terminated;           // flag indicating if the trace has reached out of u_volume bounds
    bool  exhausted;            // flag indicating if the trace has reached the max step count

    int   step_count;           // number of steps taken along the ray
    float step_distance;        // distance to be covered
    float step_scaling;         // scaling factor for step size
    float step_stretching;      // stretching factor for step size 

    vec3  position;             // current position in 3d model coordinates
    float distance;             // current distance traveled from camera
    float derivative;           // directional derivative at the sample position
    float error;

    float mean_step_distance;   // mean step distance that is covered
    float mean_step_scaling;    // mean step scaling that is covered
    float spanned_distance;     // total spanned distance from ray start
    float stepped_distance;     // total stepped distance 
    float skipped_distance;
};

Trace set_trace()
{
    Trace trace;
    trace.intersected        = false;
    trace.terminated         = false;
    trace.exhausted          = false;
    trace.step_count         = 0;
    trace.step_scaling       = 0.0;
    trace.step_stretching    = 0.0;
    trace.step_distance      = 0.0;
    trace.mean_step_scaling  = 0.0;
    trace.mean_step_distance = 0.0;
    trace.position           = vec3(0.0);
    trace.distance           = 0.0;
    trace.derivative         = 0.0;
    trace.error              = 0.0;
    trace.spanned_distance   = 0.0;
    trace.stepped_distance   = 0.0;
    trace.skipped_distance   = 0.0;
    return trace;
}
void discard_trace(inout Trace trace)
{
    trace.step_scaling       = 0.0;
    trace.step_stretching    = 0.0;
    trace.step_distance      = 0.0;
    trace.position           = vec3(0.0);
    trace.distance           = 0.0;
    trace.derivative         = 0.0;
    trace.error              = 0.0;
}

#endif // STRUCT_TRACE
