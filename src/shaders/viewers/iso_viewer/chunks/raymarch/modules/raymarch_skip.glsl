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
            // sample the volume and compute intensity at the current position
            trace.texel = trace.position * u_volume.inv_size;
            trace.value = texture(u_sampler.volume, trace.texel).r;
            trace.error = trace.value - u_raycast.threshold;

            // sample the gradients and compute normal and gradient vectors
            vec4 gradient_data = texture(u_sampler.gradients, trace.texel);
            trace.gradient_norm = gradient_data.a * u_gradient.range_norm + u_gradient.min_norm;
            trace.normal = normalize(1.0 - 2.0 * gradient_data.rgb);
            trace.gradient = - trace.normal * trace.gradient_norm;
            trace.derivative = dot(trace.gradient, ray.direction);

            // if intensity exceeds threshold and gradient is strong enough, refine the hit
            // first iteration is skipped in order to compute previous trace and we are outside of occupied block
            if (trace.error > 0.0 && gradient_data.a > u_gradient.threshold && i > 0)
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

    // Skip the block and adjust depth with a small nudge to avoid precision issues
    trace.skipped += mix(block.max_depth, 0.0, block.occupied);
    trace.distance = max_distance + nudge;
    trace.position = ray.origin + ray.direction * trace.distance;
}   
