#ifndef STRUCT_DEBUG
#define STRUCT_DEBUG

// struct to hold gradient uniforms
struct Debug 
{
    vec4 frag_depth;
    vec4 trace_intersected;
    vec4 trace_terminated;
    vec4 trace_suspended;
    vec4 ray_step_direction;
    vec4 ray_step_distance;
    vec4 ray_rand_distance;
    vec4 ray_start_distance;
    vec4 ray_end_distance;
    vec4 ray_span_distance;
    vec4 ray_start_position;
    vec4 ray_end_position;
    vec4 ray_max_step_count;
    vec4 ray_max_skip_count;
    vec4 ray_box_start_distance;
    vec4 ray_box_end_distance;
    vec4 ray_box_span_distance;
    vec4 ray_box_start_position;
    vec4 ray_box_end_position;
    vec4 trace_derivative;
    vec4 trace_distance;
    vec4 trace_gradient_magnitude;
    vec4 trace_gradient;
    vec4 trace_luminance;
    vec4 trace_mapped_color;
    vec4 trace_mean_step_scaling;
    vec4 trace_mean_step_distance;
    vec4 trace_normal;
    vec4 trace_outside;
    vec4 trace_position;
    vec4 trace_value;
    vec4 trace_value_error;
    vec4 trace_value_abs_error;
    vec4 trace_shaded_color;
    vec4 trace_skip_count;
    vec4 trace_skip_distance;
    vec4 trace_skipped_distance;
    vec4 trace_spanned_distance;
    vec4 trace_step_count;
    vec4 trace_step_distance;
    vec4 trace_delta_distance;
    vec4 trace_step_scaling;
    vec4 trace_step_stretching;
    vec4 trace_stepped_distance;
    vec4 trace_voxel_coords;
    vec4 block_value;
    vec4 block_occupied; 
    vec4 block_coords;   
    vec4 block_skip_count;
    vec4 variable1;
    vec4 variable2;
    vec4 variable3;
};

Debug set_debug()
{
    Debug debug;
    debug.frag_depth               = vec4(vec3(0.0), 1.0);
    debug.trace_intersected        = vec4(vec3(0.0), 1.0);
    debug.trace_terminated         = vec4(vec3(0.0), 1.0);
    debug.trace_suspended          = vec4(vec3(0.0), 1.0);
    debug.ray_end_distance         = vec4(vec3(0.0), 1.0);
    debug.ray_end_position         = vec4(vec3(0.0), 1.0);
    debug.ray_rand_distance        = vec4(vec3(0.0), 1.0);
    debug.ray_span_distance        = vec4(vec3(0.0), 1.0);
    debug.ray_start_distance       = vec4(vec3(0.0), 1.0);
    debug.ray_start_position       = vec4(vec3(0.0), 1.0);
    debug.ray_step_direction       = vec4(vec3(0.0), 1.0);
    debug.ray_step_distance        = vec4(vec3(0.0), 1.0);
    debug.ray_box_start_distance   = vec4(vec3(0.0), 1.0);
    debug.ray_box_end_distance     = vec4(vec3(0.0), 1.0);
    debug.ray_box_span_distance    = vec4(vec3(0.0), 1.0);
    debug.ray_box_start_position   = vec4(vec3(0.0), 1.0);
    debug.ray_box_end_position     = vec4(vec3(0.0), 1.0);
    debug.ray_max_step_count       = vec4(vec3(0.0), 1.0);
    debug.ray_max_skip_count       = vec4(vec3(0.0), 1.0);
    debug.trace_derivative         = vec4(vec3(0.0), 1.0);
    debug.trace_distance           = vec4(vec3(0.0), 1.0);
    debug.trace_gradient_magnitude = vec4(vec3(0.0), 1.0);
    debug.trace_gradient           = vec4(vec3(0.0), 1.0);
    debug.trace_luminance          = vec4(vec3(0.0), 1.0);
    debug.trace_mapped_color       = vec4(vec3(0.0), 1.0);
    debug.trace_mean_step_scaling  = vec4(vec3(0.0), 1.0);
    debug.trace_mean_step_distance = vec4(vec3(0.0), 1.0);
    debug.trace_normal             = vec4(vec3(0.0), 1.0);
    debug.trace_outside            = vec4(vec3(0.0), 1.0);
    debug.trace_position           = vec4(vec3(0.0), 1.0);
    debug.trace_value              = vec4(vec3(0.0), 1.0);
    debug.trace_value_error        = vec4(vec3(0.0), 1.0);
    debug.trace_value_abs_error    = vec4(vec3(0.0), 1.0);
    debug.trace_shaded_color       = vec4(vec3(0.0), 1.0);
    debug.trace_skip_count         = vec4(vec3(0.0), 1.0);
    debug.trace_skip_distance      = vec4(vec3(0.0), 1.0);
    debug.trace_skipped_distance   = vec4(vec3(0.0), 1.0);
    debug.trace_spanned_distance   = vec4(vec3(0.0), 1.0);
    debug.trace_step_count         = vec4(vec3(0.0), 1.0);
    debug.trace_step_distance      = vec4(vec3(0.0), 1.0);
    debug.trace_delta_distance     = vec4(vec3(0.0), 1.0);
    debug.trace_step_scaling       = vec4(vec3(0.0), 1.0);
    debug.trace_step_stretching    = vec4(vec3(0.0), 1.0);
    debug.trace_stepped_distance   = vec4(vec3(0.0), 1.0);
    debug.trace_voxel_coords       = vec4(vec3(0.0), 1.0);
    debug.block_value              = vec4(vec3(0.0), 1.0);
    debug.block_occupied           = vec4(vec3(0.0), 1.0);
    debug.block_coords             = vec4(vec3(0.0), 1.0);
    debug.block_skip_count         = vec4(vec3(0.0), 1.0);
    debug.variable1                = vec4(vec3(0.0), 1.0);
    debug.variable2                = vec4(vec3(0.0), 1.0);
    debug.variable3                = vec4(vec3(0.0), 1.0);
    return debug;
}

#endif // STRUCT_DEBUG