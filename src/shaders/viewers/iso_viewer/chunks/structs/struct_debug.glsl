#ifndef STRUCT_DEBUG
#define STRUCT_DEBUG

// struct to hold gradient uniforms
struct Debug 
{
    vec4 frag_depth;
    vec4 ray_end_distance;
    vec4 ray_end_position;
    vec4 ray_max_step_count;
    vec4 ray_rand_distance;
    vec4 ray_span_distance;
    vec4 ray_start_distance;
    vec4 ray_start_position;
    vec4 ray_step_direction;
    vec4 ray_step_distance;
    vec4 trace_block_coords;
    vec4 trace_block_lod;
    vec4 trace_block_occupancy;
    vec4 trace_block_occupied;
    vec4 trace_derivative_1st;
    vec4 trace_derivative_2nd;
    vec4 trace_derivative_3rd;
    vec4 trace_distance;
    vec4 trace_distance_error;
    vec4 trace_gradient_magnitude;
    vec4 trace_gradient;
    vec4 trace_luminance;
    vec4 trace_mapped_color;
    vec4 trace_mean_step_distance;
    vec4 trace_normal;
    vec4 trace_outside;
    vec4 trace_position;
    vec4 trace_sample_abs_error;
    vec4 trace_sample_error;
    vec4 trace_sample_value;
    vec4 trace_shaded_color;
    vec4 trace_skip_count;
    vec4 trace_skip_distance;
    vec4 trace_skipped_distance;
    vec4 trace_spanned_distance;
    vec4 trace_step_count;
    vec4 trace_step_distance;
    vec4 trace_step_scaling;
    vec4 trace_stepped_distance;
    vec4 trace_voxel_coords;
    vec4 variable1;
    vec4 variable2;
    vec4 variable3;
};

Debug set_debug()
{
    Debug debug;
    debug.frag_depth               = vec4(0.0);
    debug.ray_end_distance         = vec4(0.0);
    debug.ray_end_position         = vec4(0.0);
    debug.ray_max_step_count       = vec4(0.0);
    debug.ray_rand_distance        = vec4(0.0);
    debug.ray_span_distance        = vec4(0.0);
    debug.ray_start_distance       = vec4(0.0);
    debug.ray_start_position       = vec4(0.0);
    debug.ray_step_direction       = vec4(0.0);
    debug.ray_step_distance        = vec4(0.0);
    debug.trace_block_coords       = vec4(0.0);
    debug.trace_block_lod          = vec4(0.0);
    debug.trace_block_occupancy    = vec4(0.0);
    debug.trace_block_occupied     = vec4(0.0);
    debug.trace_derivative_1st     = vec4(0.0);
    debug.trace_derivative_2nd     = vec4(0.0);
    debug.trace_derivative_3rd     = vec4(0.0);
    debug.trace_distance           = vec4(0.0);
    debug.trace_distance_error     = vec4(0.0);
    debug.trace_gradient_magnitude = vec4(0.0);
    debug.trace_gradient           = vec4(0.0);
    debug.trace_luminance          = vec4(0.0);
    debug.trace_mapped_color       = vec4(0.0);
    debug.trace_mean_step_distance = vec4(0.0);
    debug.trace_normal             = vec4(0.0);
    debug.trace_outside            = vec4(0.0);
    debug.trace_position           = vec4(0.0);
    debug.trace_sample_abs_error   = vec4(0.0);
    debug.trace_sample_error       = vec4(0.0);
    debug.trace_sample_value       = vec4(0.0);
    debug.trace_shaded_color       = vec4(0.0);
    debug.trace_skip_count         = vec4(0.0);
    debug.trace_skip_distance      = vec4(0.0);
    debug.trace_skipped_distance   = vec4(0.0);
    debug.trace_spanned_distance   = vec4(0.0);
    debug.trace_step_count         = vec4(0.0);
    debug.trace_step_distance      = vec4(0.0);
    debug.trace_step_scaling       = vec4(0.0);
    debug.trace_stepped_distance   = vec4(0.0);
    debug.trace_voxel_coords       = vec4(0.0);
    debug.variable1                = vec4(0.0);
    debug.variable2                = vec4(0.0);
    debug.variable3                = vec4(0.0);
    return debug;
}

#endif // STRUCT_DEBUG