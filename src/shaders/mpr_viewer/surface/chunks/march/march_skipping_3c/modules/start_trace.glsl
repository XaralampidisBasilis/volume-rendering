

trace.distance_step = ray.step_distance;
trace.distance = mix(block.exit_distance, block.entry_distance - trace.distance_step, block.occupied);
