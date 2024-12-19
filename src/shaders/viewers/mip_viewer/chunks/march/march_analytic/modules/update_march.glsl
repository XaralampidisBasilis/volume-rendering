
// update trace
prev_trace = trace;
trace.distance = cell.bounds.y;
trace.position = camera.position + ray.step_direction * trace.distance; 

// update voxel
// voxel.value = max(voxel.value, cell.max_value);

if (voxel.value < cell.max_value) 
{
    voxel.value = cell.max_value;
    voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
    voxel.texture_coords = trace.position * u_volume.inv_size;
    // debug.variable1 = vec4(vec3(map(ray.min_value, ray.max_value, voxel.value)), 1.0);
    // debug.variable2 = vec4(vec3(voxel.value <= ray.min_value), 1.0);
}

// update conditions
trace.terminated = trace.distance > ray.end_distance;
trace.exhausted = trace.step_count >= ray.max_step_count;
voxel.saturated = ray.max_value - voxel.value < CENTI_TOLERANCE;

