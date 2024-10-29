
// initialize raymarch
#include "./modules/start_trace_previous"

vec3 occumap_texel_offset = vec3(occumap.offset) / vec3(occupancy_dimensions);

// raymarch loop to traverse through the volume
for (trace.steps = 0; trace.steps < ray.max_steps; trace.steps++) 
{
    block.texel = occumap_texel_offset + trace.position / occumap.spacing / vec3(occupancy_dimensions);
    block.occupied = textureLod(u_sampler.occumaps, block.texel, float(u_occupancy.min_lod)).r > 0.0;
    // block.coords = ivec3(trace.position / occumap.spacing);
    // block.occupied = texelFetch(u_sampler.occumaps, occumap.offset + block.coords, u_occupancy.min_lod).r > 0.0;

    if (block.occupied) {

        #include "./modules/sample_volume"
        ray.intersected = trace.sample_error > 0.0 && trace.gradient_magnitude > gradient_threshold;
        if (ray.intersected) break;

        trace_prev = trace;
        #include "./modules/update_trace"
    } 
    else
    {
        // compute block min and max positions in space
        block.coords = ivec3(trace.position / occumap.spacing);
        block.min_position = vec3(block.coords) * occumap.spacing;
        block.max_position = block.min_position + occumap.spacing;

        // intersect ray with block to find the skipping distance
        block.skipping = intersect_box_max(block.min_position, block.max_position, trace.position, ray.step_direction);
        block.skipping += length(occumap.spacing) * MILLI_TOL; // add small values to avoid numerical instabilities in block boundaries

        #include "./modules/update_block_position"
    }

    if (trace.distance > ray.end_distance) break;
}   

