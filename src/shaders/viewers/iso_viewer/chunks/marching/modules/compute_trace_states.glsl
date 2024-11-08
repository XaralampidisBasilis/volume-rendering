
// if trace distance exceeds the ray bounds then we assume marching is terminated
trace.terminated = abs(ray.span_distance) < PICO_TOLERANCE || trace.distance > ray.end_distance;

// if trace step count exceeds the ray max count then we assume marching is susspended
trace.suspended = !trace.terminated && trace.step_count >= RAY_MAX_STEP_COUNT;

// if trace sample value exceeds the sample threshold then we assume there was an intersection
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;
