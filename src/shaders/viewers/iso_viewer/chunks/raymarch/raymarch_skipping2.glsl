
// skip initial empty space
// #include "./modules/compute_skipping"

occumap.lod = 5;
occumap.lod_scale = exp2(float(occumap.lod));
occumap.dimensions = occupancy_base_dimensions / int(occumap.lod_scale);
occumap.spacing = occupancy_base_spacing * occumap.lod_scale;

occumap.offset.y = occupancy_base_dimensions.y - 2 * occumap.dimensions.y;
occumap.offset.z = occupancy_base_dimensions.z;
if (occumap.lod < 1) occumap.offset = ivec3(0);

occumap.max_skips = mmax(occumap.dimensions);
occumap.max_skips = min(occumap.max_skips, occupancy_max_skips);

block.spacing = length(occumap.spacing) * 0.5;

// initialize raymarch
#include "./modules/initialize_trace"

// raymarch loop to traverse through the volume
for (block.skips = 0; block.skips < occumap.max_skips; block.skips++) 
{
    #include "./modules/update_block_sample"
    
    if (block.occupied) 
    {
        #include "./raymarch_block"
    } 
    else 
    {
        #include "./modules/update_block_position"
    }

    if (trace.distance > ray.max_distance) break;
}   

