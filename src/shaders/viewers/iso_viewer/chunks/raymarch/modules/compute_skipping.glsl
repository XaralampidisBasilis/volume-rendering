
#include "./initialize_occumap"

for (block.skips = 0; block.skips < occumap.max_skips; block.skips++) 
{
    #include "update_occumap_sample"

    if (block.occupied) {
        if (occumap.lod < 1) break; 
        #include "./update_occumap_lod"
        
    } else {
        #include "./update_occumap_block"
        if (trace.distance > ray.max_distance) break;
    }
}

// update trace position
trace.spacing = - 2.0 * trace.spacing;
trace.skipped += trace.spacing;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * u_volume.inv_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * inv_volume_spacing);
