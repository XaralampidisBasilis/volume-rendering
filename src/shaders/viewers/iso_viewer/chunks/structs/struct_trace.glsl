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

    float mean_step_distance;   // mean step distance that is covered
    float mean_step_scaling;    // mean step scaling that is covered
    float spanned_distance;     // total spanned distance from ray start
    float stepped_distance;     // total stepped distance 

    vec4  mapped_color;         // color mapped from the voxel value
    vec4  shaded_color;         // color after shading has been applied
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
    trace.spanned_distance   = 0.0;
    trace.stepped_distance   = 0.0;
    trace.mapped_color       = vec4(vec3(0.0), 1.0);
    trace.shaded_color       = vec4(vec3(0.0), 1.0);
    return trace;
}
void discard_trace(inout Trace trace)
{
    trace.intersected        = trace.intersected;
    trace.terminated         = trace.terminated;
    trace.exhausted          = trace.exhausted;
    trace.step_count         = trace.step_count;
    trace.step_scaling       = trace.step_scaling;
    trace.step_stretching    = trace.step_stretching;
    trace.step_distance      = trace.step_distance;
    trace.mean_step_scaling  = trace.mean_step_scaling;
    trace.mean_step_distance = trace.mean_step_distance;
    trace.position           = trace.position;
    trace.distance           = trace.distance;
    trace.derivative         = trace.derivative;
    trace.spanned_distance   = trace.spanned_distance;
    trace.stepped_distance   = trace.stepped_distance;
    trace.mapped_color       = trace.mapped_color;
    trace.shaded_color       = trace.shaded_color;
}


#endif // STRUCT_TRACE
