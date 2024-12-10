
// update derivative
trace.derivative = dot(voxel.gradient, ray.step_direction);
trace.error = proj_voxel.value - voxel.value;

// update step
trace.step_distance = (trace.error + CENTI_TOLERANCE) / trace.derivative;
trace.step_distance = trace.derivative > 0.0 ? trace.step_distance : ray.max_step_distance;
trace.step_distance = clamp(trace.step_distance, ray.min_step_distance, ray.max_step_distance);
trace.step_scaling = trace.step_distance / ray.step_distance;

// update position
trace.distance += trace.step_distance;
trace.position = camera.position + ray.step_direction * trace.distance; 

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.exhausted = trace.step_count >= ray.max_step_count;

// update cumulatives
trace.stepped_distance += trace.step_distance;
trace.mean_step_scaling = trace.step_scaling + trace.mean_step_scaling * float(trace.step_count);
trace.mean_step_distance = trace.step_distance + trace.mean_step_distance * float(trace.step_count);
trace.mean_step_scaling /= float(trace.step_count + 1);
trace.mean_step_distance /= float(trace.step_count + 1);
