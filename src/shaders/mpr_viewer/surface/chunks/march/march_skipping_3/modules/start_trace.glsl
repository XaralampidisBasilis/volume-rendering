
trace.distance_step = ray.step_distance * 2.0;
trace.distance = mix(block.exit_distance, block.entry_distance - trace.distance_step, block.occupied);
