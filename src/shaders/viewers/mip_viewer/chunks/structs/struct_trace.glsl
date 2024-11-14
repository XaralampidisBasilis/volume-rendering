#ifndef STRUCT_TRACE
#define STRUCT_TRACE

// struct to hold information about the current ray trace 
struct Trace 
{
    bool  intersected;          // flag indicating if the trace intersected with the u_volume
    bool  terminated;           // flag indicating if the trace has reached out of u_volume bounds
    bool  suspended;            // flag indicating if the trace has reached the max step count
    bool  update;               // flag indicating if the trace can continue marching

    int   step_count;           // number of steps taken along the ray
    int   skip_count;           // number of skipped steps along the ray

    float step_distance;        // distance to be covered
    float backstep_distance;    // distance to backstep
    float skip_distance;        // distance to be skipped
    float rand_distance;        // random distance for dithering
    
    float step_scaling;         // scaling factor for step size
    float min_step_scaling;     // min scaling factor for step size 
    float max_step_scaling;     // max scaling factor for step size 

    float step_stretching;      // stretching factor for step size 
    float min_step_stretching;  // min stretching factor for step size 
    float max_step_stretching;  // max stretching factor for step size 
    float range_step_stretching;// range stretching factor for step size 

    float mean_step_distance;  // mean step distance that is covered
    float mean_step_scaling;   // mean step scaling that is covered

    vec3  position;             // current position in 3d model coordinates
    float distance;             // current distance traveled from camera
    float spanned_distance;     // total spanned distance from ray start
    float stepped_distance;     // total stepped distance 
    float skipped_distance;     // total skipped distance 

    vec4  sample_data;          // sampled data at the current position
    float sample_value;         // sampled value at the current position
    float sample_error;         // sampled error associated with the difference of the sample value from the threshold

    ivec3 voxel_coords;         // integer voxel coordinates in 3d space
    vec3  voxel_texture_coords; // normalized voxel texture coordinates

    vec3  normal;               // normal vector
    vec3  gradient;             // gradient vector
    vec3  gradient_direction;   // direction of the gradient vector
    float gradient_magnitude;   // magnitude of the gradient vector
    float derivative;           // directional derivative at the sample position

    vec4  mapped_color;         // color mapped from the sample value
    vec4  shaded_color;         // color after shading has been applied
};

Trace set_trace()
{
    Trace trace;
    trace.intersected = false;
    trace.terminated = false;
    trace.suspended = false;
    trace.update = true;
    trace.step_count = 0;
    trace.skip_count = 0;
    trace.step_scaling = 0.0;      
    trace.min_step_scaling = 0.0;      
    trace.max_step_scaling = 0.0;   
    trace.mean_step_scaling = 0.0;    
    trace.step_stretching = 0.0;     
    trace.min_step_stretching = 0.0;     
    trace.max_step_stretching = 0.0;     
    trace.range_step_stretching = 0.0;   
    trace.step_distance = 0.0;
    trace.mean_step_distance = 0.0;
    trace.backstep_distance = 0.0;
    trace.skip_distance = 0.0;
    trace.rand_distance = 0.0;
    trace.position = vec3(0.0);
    trace.distance = 0.0;
    trace.spanned_distance = 0.0;
    trace.stepped_distance = 0.0;
    trace.skipped_distance = 0.0;
    trace.sample_data = vec4(0.0);
    trace.sample_value = 0.0;
    trace.sample_error = 0.0;
    trace.voxel_coords = ivec3(0);
    trace.voxel_texture_coords = vec3(0.0);
    trace.normal = vec3(0.0);
    trace.gradient = vec3(0.0);
    trace.gradient_direction = vec3(0.0);
    trace.gradient_magnitude = 0.0;
    trace.derivative = 0.0;
    trace.mapped_color = vec4(vec3(0.0), 1.0);
    trace.shaded_color = vec4(vec3(0.0), 1.0);
    return trace;
}

#endif // STRUCT_TRACE
