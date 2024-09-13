// ray
ray.origin       = v_camera;
ray.direction    = normalize(v_direction);
ray.box_min      = vec3(0.0);
ray.box_max      = u_volume.size;
ray.spacing      = 0.0;
ray.dithering    = 0.0;
ray.min_distance = 0.0;
ray.max_distance = 0.0;
ray.max_depth    = 0.0;
ray.min_spacing  = 0.0;
ray.max_spacing  = 0.0;
ray.max_steps    = 0;
ray.intersected  = false;

// trace 
trace.position       = ray.origin;
trace.texel          = ray.origin * u_volume.inv_size;
trace.coords         = vec3(0.0);
trace.normal         = vec3(0.0); 
trace.gradient       = vec3(0.0); 
trace.color          = vec3(0.0);
trace.shading        = vec3(0.0);
trace.value          = 0.0;  
trace.error          = 0.0;  
trace.distance       = 0.0;
trace.depth          = 0.0;
trace.skipped        = 0.0;
trace.traversed      = 0.0;
trace.stepping       = 0.0;
trace.spacing        = 0.0;
trace.gradient_norm  = 0.0;
trace.derivative     = 0.0;
trace.steps          = 0;

// prev_trace
prev_trace.position       = trace.position;
prev_trace.texel          = trace.texel;
prev_trace.coords         = vec3(0.0);
prev_trace.normal         = vec3(0.0); 
prev_trace.gradient       = vec3(0.0); 
prev_trace.color          = vec3(0.0);
prev_trace.shading        = vec3(0.0);
prev_trace.value          = 0.0;  
prev_trace.error          = 0.0;  
prev_trace.distance       = 0.0;
prev_trace.depth          = 0.0;
prev_trace.skipped        = 0.0;
prev_trace.traversed      = 0.0;
prev_trace.stepping       = 0.0;
prev_trace.spacing        = 0.0;
prev_trace.gradient_norm  = 0.0;
prev_trace.derivative     = 0.0;
prev_trace.steps          = 0;

// block
block.coords       = ivec3(0);
block.min_position = vec3(0.0);
block.max_position = vec3(0.0);
block.size         = vec3(0.0);
block.resolutuon   = 0.0;
block.max_depth    = 0.0;
block.max_steps    = 0;
block.occupied     = false;

// debug
debug.trace_position      = vec4(0.0);
debug.trace_distance      = vec4(0.0);
debug.trace_depth         = vec4(0.0);
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
debug.trace_stepping      = vec4(0.0);
debug.trace_mean_stepping = vec4(0.0);
debug.ray_direction       = vec4(0.0);
debug.ray_spacing         = vec4(0.0);
debug.ray_dithering       = vec4(0.0);
debug.ray_min_distance    = vec4(0.0);
debug.ray_max_distance    = vec4(0.0);
debug.ray_max_depth       = vec4(0.0);
debug.ray_max_steps       = vec4(0.0);
debug.frag_depth          = vec4(0.0);
