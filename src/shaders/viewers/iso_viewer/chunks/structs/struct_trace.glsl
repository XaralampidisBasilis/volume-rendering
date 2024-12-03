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
    float step_distance;        // distance to be covered
    float skip_distance;        // distance to be skipped
    float step_scaling;         // scaling factor for step size
    float step_stretching;      // stretching factor for step size 

    vec3  position;             // current position in 3d model coordinates
    float distance;             // current distance traveled from camera
    ivec3 voxel_coords;         // integer voxel coordinates in 3d space
    vec3  voxel_texels;         // normalized voxel texture coordinates

    float value;                // sampled value at the current position
    float value_error;          // sampled error associated with the difference of the sample value from the threshold

    vec3  normal;               // normal vector
    vec3  gradient;             // gradient vector
    vec3  gradient_direction;   // direction of the gradient vector
    float gradient_magnitude;   // magnitude of the gradient vector
    float derivative;           // directional derivative at the sample position

    vec4  mapped_color;         // color mapped from the sample value
    vec4  shaded_color;         // color after shading has been applied

    float mean_step_distance;   // mean step distance that is covered
    float mean_step_scaling;    // mean step scaling that is covered
    float spanned_distance;     // total spanned distance from ray start
    float stepped_distance;     // total stepped distance 
    float skipped_distance;     // total skipped distance 
};

Trace set_trace()
{
    Trace trace;
    trace.intersected        = false;
    trace.terminated         = false;
    trace.suspended          = false;
    trace.update             = true;
    trace.step_count         = 0;
    trace.step_scaling       = 0.0;
    trace.step_stretching    = 0.0;
    trace.step_distance      = 0.0;
    trace.mean_step_scaling  = 0.0;
    trace.mean_step_distance = 0.0;
    trace.skip_distance      = 0.0;
    trace.position           = vec3(0.0);
    trace.distance           = 0.0;
    trace.spanned_distance   = 0.0;
    trace.stepped_distance   = 0.0;
    trace.skipped_distance   = 0.0;
    trace.value              = 0.0;
    trace.value_error        = 0.0;
    trace.voxel_coords       = ivec3(0);
    trace.voxel_texels       = vec3(0.0);
    trace.normal             = vec3(0.0);
    trace.gradient           = vec3(0.0);
    trace.gradient_direction = vec3(0.0);
    trace.gradient_magnitude = 0.0;
    trace.derivative         = 0.0;
    trace.mapped_color       = vec4(vec3(0.0), 1.0);
    trace.shaded_color       = vec4(vec3(0.0), 1.0);
    return trace;
}
void discard_trace(inout Trace trace)
{
    trace.intersected        = trace.intersected;        
    trace.terminated         = trace.terminated;         
    trace.suspended          = trace.suspended;          
    trace.update             = trace.update;             
    trace.step_count         = trace.step_count;         
    trace.step_scaling       = trace.step_scaling;       
    trace.step_stretching    = trace.step_stretching;    
    trace.step_distance      = trace.step_distance;      
    trace.mean_step_scaling  = trace.mean_step_scaling;  
    trace.mean_step_distance = trace.mean_step_distance; 
    trace.skip_distance      = trace.skip_distance;      
    trace.position           = trace.position;           
    trace.distance           = trace.distance;           
    trace.spanned_distance   = trace.spanned_distance;   
    trace.stepped_distance   = trace.stepped_distance;   
    trace.skipped_distance   = trace.skipped_distance;   
    trace.value              = trace.value;              
    trace.value_error        = trace.value_error;        
    trace.voxel_coords       = trace.voxel_coords;       
    trace.voxel_texels       = trace.voxel_texels;       
    trace.normal             = trace.normal;             
    trace.gradient           = trace.gradient;           
    trace.gradient_direction = trace.gradient_direction; 
    trace.gradient_magnitude = trace.gradient_magnitude; 
    trace.derivative         = trace.derivative;         
    trace.mapped_color       = trace.mapped_color;       
    trace.shaded_color       = trace.shaded_color;       
}


#endif // STRUCT_TRACE
