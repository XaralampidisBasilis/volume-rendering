
// raymarch loop to traverse through the volume
for (trace.step_count = 0; trace.step_count < ray.max_step_count && trace.distance < ray.end_distance; trace.step_count++) 
{
    #include "./modules/sample_volume"
    if (trace.sample_error > 0.0) break;
        
    #include "./modules/update_trace"
}   

ray.intersected = trace.sample_error > 0.0;
ray.terminated = trace.distance > ray.end_distance;
ray.depleted = trace.step_count > ray.max_step_count;