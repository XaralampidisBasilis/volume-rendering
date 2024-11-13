
// update condition
trace.suspended = trace.step_count > u_raymarch.max_step_count;
trace.terminated = trace.distance > ray.end_distance;
trace.intersected = trace.sample_value > u_raymarch.sample_threshold;
trace.update = !(trace.intersected || trace.terminated || trace.suspended);
