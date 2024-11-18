
// update condition
trace.suspended = trace.step_count > u_raymarch.max_step_count;
trace.terminated = trace.distance > ray.end_distance;
trace.update = !(trace.terminated || trace.suspended);