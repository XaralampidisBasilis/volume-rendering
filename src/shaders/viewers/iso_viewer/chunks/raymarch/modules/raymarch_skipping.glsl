
block.lod = int(u_occumaps.lods - 1);
int scaling_lod = int(exp2(float(block.lod)));
ivec3 occumap_dimensions = u_occumaps.base_dimensions / scaling_lod;
block.size = u_occumaps.base_spacing * float(scaling_lod);

ivec3 occumap_offset;
occumap_offset.x = 0;
occumap_offset.y = block.lod > 0 ? u_occumaps.base_dimensions.y - 2 * occumap_dimensions.y: 0;
occumap_offset.z = block.lod > 0 ? u_occumaps.base_dimensions.z : 0;

for(int counter = 0; counter < u_debug.number; counter++)
{
    block.coords = ivec3(trace.position / block.size);
    block.occupancy = texelFetch(u_sampler.occumaps, block.coords + occumap_offset, 0).r;
    block.occupied = block.occupancy > u_occupancy.threshold;

    if (!block.occupied)
    {
       block.min_position = vec3(block.coords) * block.size;
       block.max_position = block.min_position + block.size;
       block.skip_depth = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction);

        trace.spacing = block.skip_depth + ray.min_spacing * 0.1;
        trace.distance += trace.spacing;
        trace.position += ray.direction * trace.spacing;
        trace.texel = trace.position * u_volume.inv_size;
        if (trace.distance > ray.max_distance) break;
    }
    else
    {
        if (block.lod == 0) break;
        block.lod--;
        scaling_lod = int(exp2(float(block.lod)));
        occumap_dimensions = u_occumaps.base_dimensions / scaling_lod;
        block.size = u_occumaps.base_spacing * float(scaling_lod);

        occumap_offset.x = 0;
        occumap_offset.y = block.lod > 0 ? u_occumaps.base_dimensions.y - 2 * occumap_dimensions.y: 0;
        occumap_offset.z = block.lod > 0 ? u_occumaps.base_dimensions.z : 0;

    }
}


// Precompute invariant values outside the loop to avoid redundant work
float raycast_threshold = u_raycast.threshold;
float gradient_threshold = u_gradient.threshold;
vec3 inv_volume_size = u_volume.inv_size;
vec3 inv_volume_spacing = u_volume.inv_spacing;
float inv_gradient_max_norm = 1.0 / u_gradient.max_norm;

ray.intersected = false;    

// Raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps && trace.distance < ray.max_distance; trace.steps++) 
{
    // Extract intensity and gradient from volume data in a single texture lookup
    vec4 volume_data = texture(u_sampler.volume, trace.texel);
    trace.value = volume_data.r;
    trace.error = trace.value - raycast_threshold;

    // Compute the gradient and its norm in a single step
    trace.gradient = mix(u_gradient.min, u_gradient.max, volume_data.gba);
    float gradient_norm = length(trace.gradient) * inv_gradient_max_norm;

    // Compute normalized gradient for further calculations
    trace.normal = -normalize(trace.gradient);
    
    // Include derivative calculations
    #include "../../derivatives/compute_derivatives"

    // If intensity exceeds threshold and gradient is strong enough, register an intersection
    if (trace.error > 0.0 && gradient_norm > gradient_threshold && trace.steps > 0) 
    {   
        ray.intersected = true;         
        break;
    }

    // Save the previous trace state
    #include "../../parameters/save_prev_trace"
    
    // Precompute stepping for the first iteration
    if (trace.steps == 0) {
        trace.stepping = u_raycast.min_stepping;
    } else {
        // Compute stepping normally for subsequent iterations
        #include "../../stepping/compute_stepping"
    }

    // Update ray position for the next step
    trace.spacing = trace.stepping * ray.spacing;
    trace.distance += trace.spacing;
    trace.position += ray.direction * trace.spacing;
    trace.texel = trace.position * inv_volume_size;
}   

// Compute the final depth and coordinates
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);
prev_trace.depth = prev_trace.distance - ray.min_distance;
prev_trace.coords = floor(prev_trace.position * inv_volume_spacing);
