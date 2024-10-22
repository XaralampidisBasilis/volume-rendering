
#include "./initialize_occumap"

for (int steps = 0; steps < MAX_SKIPPING_STEPS; steps++) 
{
    #include "update_occumap_sample"

    if (block.occupied) 
    {
        if (block.lod < 1) break; 
        #include "./update_occumap_lod"
    } 
    else 
    {
        #include "./update_occumap_block"
        if (trace.distance > ray.max_distance) break;
    }
}

// update trace position
trace.spacing = - ray.spacing * 2.0;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * u_volume.inv_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);
