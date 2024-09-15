
// define parameters
parameters_ray   ray;
parameters_trace trace;
parameters_trace prev_trace;
parameters_block block;
parameters_debug debug;

// set parameters
set_ray(ray);
set_trace(trace);
set_trace(prev_trace);
set_block(block);
set_debug(debug);

ray.origin          = v_camera;
ray.direction       = normalize(v_direction);
ray.box_min         = vec3(0.0);
ray.box_max         = u_volume.size;

trace.position      = ray.origin;
trace.texel         = ray.origin * u_volume.inv_size;

prev_trace.position = trace.position;
prev_trace.texel    = trace.texel;
