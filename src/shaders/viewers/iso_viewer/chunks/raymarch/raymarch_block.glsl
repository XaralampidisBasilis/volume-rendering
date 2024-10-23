
block.distance = trace.distance;
block.max_steps = int(block.skipping / ray.min_spacing);

// #include "./modules/refine_trace_position"

// raymarch loop to traverse through the volume
for (block.steps = 0; block.steps < block.max_steps; block.steps++) 
{
    #include "./modules/update_trace_sample"

    ray.intersected = trace.error > 0.0 && length(trace.gradient) > gradient_threshold;
    if (ray.intersected) break;

    prev_trace = trace;
    #include "./modules/update_trace_position"
    if (trace.distance - block.distance > block.skipping) break;
}   

 