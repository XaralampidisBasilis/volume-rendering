
// compute step distance based on taylor expansion 
trace.step_distance = -trace.value_error / trace.derivative;
trace.step_distance = trace.derivative > 0.0 ? trace.step_distance : ray.max_step_distance; 
trace.step_distance = clamp(trace.step_distance, ray.min_step_distance, ray.max_step_distance); 
trace.step_scaling = trace.step_distance / ray.step_distance;

// exponential distance stretching profile
float camera_angle = dot(ray.step_direction, camera.direction);
trace.step_stretching = 2.0 - smoothstep(0.8, 1.0, camera_angle);
trace.step_stretching *= trace.distance * u_volume.size_length * 2.0;
trace.step_stretching = clamp(trace.step_stretching, 0.4, 1.0);

// apply stretching base on camera
trace.step_distance *= trace.step_stretching;
trace.step_distance = clamp(trace.step_distance, ray.min_step_distance, ray.max_step_distance);

