ray.intersected = false;         
float nudge = mmin(u_volume.spacing * u_occupancy.block_dimensions) * 0.001;
float backstep = ray.max_spacing + ray.dithering;

for (
    trace.steps = 0; 
    trace.steps < ray.max_steps && trace.distance < ray.max_distance; 
    trace.steps++
) 
{
    // check if the current block is occupied and compute skip depth
    #include "./compute_skipping"
    float max_distance = min(trace.distance + block.max_depth, ray.max_distance);

    if (block.occupied) 
    {            
        // adjust the trace depth and position by backstepping
        trace.distance -= backstep;
        trace.position = ray.origin + ray.direction * trace.distance;

        block.max_depth += backstep;
        block.max_steps = int(ceil(block.max_depth / ray.min_spacing));

        // traverse through occupied block
        for(int i = 0; i < block.max_steps && trace.distance < max_distance; i++, trace.steps++) 
        {
            // Extract intensity value from volume data
            trace.texel = trace.position * u_volume.inv_size;
            vec4 volume_data = texture(u_sampler.volume, trace.texel);
            trace.value = volume_data.r;
            trace.error = trace.value - u_raycast.threshold;

            // Extract gradient from volume data
            trace.gradient = (2.0 * volume_data.gba - 1.0) * u_gradient.max_norm;
            trace.gradient_norm = length(trace.gradient);
            trace.normal = - normalize(trace.gradient);
            trace.derivative = dot(trace.gradient, ray.direction);
            float gradient_slope = trace.gradient_norm / u_gradient.max_norm;

            // if intensity exceeds threshold and gradient is strong enough, refine the hit
            // first iteration is skipped in order to compute previous trace and we are outside of occupied block
            if (trace.error > 0.0 && gradient_slope > u_gradient.threshold && i > 0)
            {   
                ray.intersected = true;                    
                break;
            }

            // save previous trace
            #include "../../parameters/save_prev_trace"

            // prepare for the next step, update trace and ray position
            #include "../../stepping/compute_stepping"
            trace.spacing = trace.stepping * ray.spacing;
            trace.position += ray.direction * trace.spacing;
            trace.distance += trace.spacing;
        }       
    }
    if(ray.intersected) break;

    // Skip the block and adjust depth with a small nudge to avoid precision issues
    trace.skipped += mix(block.max_depth, 0.0, block.occupied);
    trace.distance = max_distance + nudge;
    trace.position = ray.origin + ray.direction * trace.distance;
}   

trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * u_volume.inv_spacing);
prev_trace.depth = prev_trace.distance - ray.min_distance;
prev_trace.coords = floor(prev_trace.position * u_volume.inv_spacing);