
// define parameters
parameters_ray   ray;
parameters_trace trace;
parameters_trace prev_trace;
parameters_block block;
parameters_debug debug;

// set parameters
set_ray(ray);
set_trace(trace);
set_block(block);
set_debug(debug);

ray.origin = v_camera;
ray.direction = normalize(v_direction);

trace.position = ray.origin;
trace.texel = ray.origin * u_volume.inv_size;
trace.stepping = u_raycast.min_stepping;

#include "./save_prev_trace"
