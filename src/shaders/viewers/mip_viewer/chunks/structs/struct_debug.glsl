#ifndef STRUCT_DEBUG
#define STRUCT_DEBUG

// struct to hold gradient uniforms
struct Debug 
{
    vec4 frag_depth;                  
    vec4 ray_camera_position;         
    vec4 ray_camera_direction;        
    vec4 ray_step_direction;          
    vec4 ray_step_distance;           
    vec4 ray_rand_distance;           
    vec4 ray_start_distance;          
    vec4 ray_end_distance;            
    vec4 ray_span_distance;           
    vec4 ray_start_position;          
    vec4 ray_end_position;            
    vec4 ray_max_step_count;          
    vec4 ray_min_start_distance;      
    vec4 ray_max_end_distance;        
    vec4 ray_max_span_distance;       
    vec4 trace_terminated;            
    vec4 trace_suspended;             
    vec4 trace_distance;              
    vec4 trace_position;              
    vec4 trace_voxel_coords;          
    vec4 trace_step_count;            
    vec4 trace_step_distance;         
    vec4 trace_step_scaling;          
    vec4 trace_mean_step_scaling;     
    vec4 trace_mean_step_distance;    
    vec4 max_trace_distance;          
    vec4 max_trace_position;          
    vec4 max_trace_voxel_coords;      
    vec4 max_trace_step_count;        
    vec4 max_trace_step_distance;     
    vec4 max_trace_step_scaling;     
    vec4 max_trace_sample_value;      
    vec4 max_trace_mapped_color;      
    vec4 max_trace_gradient;          
    vec4 max_trace_gradient_magnitude;
    vec4 max_trace_gradient_direction;
    vec4 max_trace_derivative;  
    vec4 variable1;
    vec4 variable2;
    vec4 variable3;      
};

Debug set_debug()
{
    Debug debug;
    debug.frag_depth                   = vec4(vec3(0.0), 1.0);
    debug.ray_camera_position          = vec4(vec3(0.0), 1.0);
    debug.ray_camera_direction         = vec4(vec3(0.0), 1.0);
    debug.ray_step_direction           = vec4(vec3(0.0), 1.0);
    debug.ray_step_distance            = vec4(vec3(0.0), 1.0);
    debug.ray_rand_distance            = vec4(vec3(0.0), 1.0);
    debug.ray_start_distance           = vec4(vec3(0.0), 1.0);
    debug.ray_end_distance             = vec4(vec3(0.0), 1.0);
    debug.ray_span_distance            = vec4(vec3(0.0), 1.0);
    debug.ray_start_position           = vec4(vec3(0.0), 1.0);
    debug.ray_end_position             = vec4(vec3(0.0), 1.0);
    debug.ray_max_step_count           = vec4(vec3(0.0), 1.0);
    debug.ray_min_start_distance       = vec4(vec3(0.0), 1.0);
    debug.ray_max_end_distance         = vec4(vec3(0.0), 1.0);
    debug.ray_max_span_distance        = vec4(vec3(0.0), 1.0);
    debug.trace_terminated             = vec4(vec3(0.0), 1.0);
    debug.trace_suspended              = vec4(vec3(0.0), 1.0);
    debug.trace_distance               = vec4(vec3(0.0), 1.0);
    debug.trace_position               = vec4(vec3(0.0), 1.0);
    debug.trace_voxel_coords           = vec4(vec3(0.0), 1.0);
    debug.trace_step_count             = vec4(vec3(0.0), 1.0);
    debug.trace_step_distance          = vec4(vec3(0.0), 1.0);
    debug.trace_step_scaling           = vec4(vec3(0.0), 1.0);
    debug.trace_mean_step_scaling      = vec4(vec3(0.0), 1.0);
    debug.trace_mean_step_distance     = vec4(vec3(0.0), 1.0);
    debug.max_trace_distance           = vec4(vec3(0.0), 1.0);
    debug.max_trace_position           = vec4(vec3(0.0), 1.0);
    debug.max_trace_voxel_coords       = vec4(vec3(0.0), 1.0);
    debug.max_trace_step_count         = vec4(vec3(0.0), 1.0);
    debug.max_trace_step_distance      = vec4(vec3(0.0), 1.0);
    debug.max_trace_step_scaling       = vec4(vec3(0.0), 1.0);
    debug.max_trace_sample_value       = vec4(vec3(0.0), 1.0);
    debug.max_trace_mapped_color       = vec4(vec3(0.0), 1.0);
    debug.max_trace_gradient           = vec4(vec3(0.0), 1.0);
    debug.max_trace_gradient_magnitude = vec4(vec3(0.0), 1.0);
    debug.max_trace_gradient_direction = vec4(vec3(0.0), 1.0);
    debug.max_trace_derivative         = vec4(vec3(0.0), 1.0);
    debug.variable1                    = vec4(vec3(0.0), 1.0);
    debug.variable2                    = vec4(vec3(0.0), 1.0);
    debug.variable3                    = vec4(vec3(0.0), 1.0);
    return debug;
}

#endif // STRUCT_DEBUG