
// raymarch loop to traverse through the volume
for (trace.step_count = 0; trace.step_count < ray.max_step_count; ) 
{
    #include "./modules/sample_volume"
    if (ray.intersected) break;

    #include "./modules/update_trace"
    if (trace.distance > ray.end_distance) break;
}   

