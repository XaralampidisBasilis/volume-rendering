
// update condition
trace.intersected = trace.sample_value >= u_raymarch.max_sample_value;
trace.suspended = trace.step_count > u_raymarch.max_step_count;
trace.terminated = trace.distance > ray.end_distance;
trace.update = !(trace.intersected || trace.terminated || trace.suspended);