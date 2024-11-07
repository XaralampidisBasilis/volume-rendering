
// if trace distance exceeds the ray bounds then we assume marching is terminated
trace.terminated = abs(ray.span_distance) < PICO_TOLERANCE || trace.distance > ray.end_distance;

// if trace step count exceeds the ray max count then we assume marching is susspended
trace.suspended = !trace.terminated && trace.step_count >= ray.max_step_count;

// if trace sample value exceeds the sample threshold then we assume there was an intersection
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;
