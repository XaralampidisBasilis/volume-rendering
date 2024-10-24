#ifndef PARAMETERS_DEBUG
#define PARAMETERS_DEBUG

// struct to hold gradient uniforms
struct parameters_debug 
{
    vec4 trace_position;  
    vec4 trace_coords;  
    vec4 trace_distance;      
    vec4 trace_depth;         
    vec4 trace_outside;         
    vec4 trace_traversed;     
    vec4 trace_skipped;       
    vec4 trace_steps;         
    vec4 trace_value;         
    vec4 trace_error;         
    vec4 trace_abs_error;     
    vec4 trace_color;         
    vec4 trace_shading;       
    vec4 trace_luminance;
    vec4 trace_normal;        
    vec4 trace_gradient;      
    vec4 trace_gradient_norm; 
    vec4 trace_derivative;    
    vec4 trace_derivative2;    
    vec4 trace_derivative3;    
    vec4 trace_stepping;      
    vec4 trace_mean_stepping; 
    vec4 ray_direction;       
    vec4 ray_spacing;         
    vec4 ray_dithering;        
    vec4 ray_min_distance;    
    vec4 ray_max_distance;    
    vec4 ray_max_depth;       
    vec4 ray_max_steps;  
    vec4 block_lod;
    vec4 block_occupancy;
    vec4 block_occupied;
    vec4 block_skipping;
    vec4 block_coords;
    vec4 block_min_position;
    vec4 block_max_position;   
    vec4 block_skips;  
    vec4 frag_depth;        
    vec4 variable1;  
    vec4 variable2;  
    vec4 variable3;  
};

void set(out parameters_debug debug)
{
    debug.trace_position      = vec4(0.0);
    debug.trace_coords        = vec4(0.0);
    debug.trace_distance      = vec4(0.0);
    debug.trace_depth         = vec4(0.0);
    debug.trace_outside       = vec4(0.0);
    debug.trace_traversed     = vec4(0.0);
    debug.trace_skipped       = vec4(0.0);
    debug.trace_steps         = vec4(0.0);
    debug.trace_value         = vec4(0.0);
    debug.trace_error         = vec4(0.0);
    debug.trace_abs_error     = vec4(0.0);
    debug.trace_color         = vec4(0.0);
    debug.trace_shading       = vec4(0.0);
    debug.trace_luminance     = vec4(0.0);
    debug.trace_normal        = vec4(0.0);
    debug.trace_gradient      = vec4(0.0);
    debug.trace_gradient_norm = vec4(0.0);
    debug.trace_derivative    = vec4(0.0);
    debug.trace_derivative2   = vec4(0.0);
    debug.trace_derivative3   = vec4(0.0);
    debug.trace_stepping      = vec4(0.0);
    debug.trace_mean_stepping = vec4(0.0);
    debug.ray_direction       = vec4(0.0);
    debug.ray_spacing         = vec4(0.0);
    debug.ray_dithering       = vec4(0.0);
    debug.ray_min_distance    = vec4(0.0);
    debug.ray_max_distance    = vec4(0.0);
    debug.ray_max_depth       = vec4(0.0);
    debug.ray_max_steps       = vec4(0.0);
    debug.block_lod           = vec4(0.0);
    debug.block_occupancy     = vec4(0.0);
    debug.block_occupied      = vec4(0.0);
    debug.block_skipping      = vec4(0.0);
    debug.block_coords        = vec4(0.0);
    debug.block_min_position  = vec4(0.0);
    debug.block_max_position  = vec4(0.0);
    debug.block_skips         = vec4(0.0);
    debug.frag_depth          = vec4(0.0);
    debug.variable1           = vec4(0.0);
    debug.variable2           = vec4(0.0);
    debug.variable3           = vec4(0.0);
}

#endif