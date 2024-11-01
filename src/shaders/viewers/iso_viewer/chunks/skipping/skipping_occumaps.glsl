// start occumap to the max level of detail
#include "./modules/start_occumap"

// skip initial empty space with multiresolution occumapncy maps
for (trace.skip_count = 0; trace.skip_count < raymarch.max_skip_count; ) 
{
    // sample occumap at the current block to see if is occupied
    #include "./modules/sample_occumaps"

    if (trace.block_occupied)  
    {
        // if block is occupied get to a lower level occumap
        #include "./modules/update_occumap"
    }
    else
    {
        // if not occupied block, skip to the next
        #include "./modules/update_block"
    }
}

// if last block is occupuied then refine the position of the trace
if (trace.block_occupied)  
{
    // compute final occupied block bounds in model space
    vec3 block_min_position = vec3(trace.block_coords + 0);
    vec3 block_max_position = vec3(trace.block_coords + 1);
    block_min_position *= occumap.spacing;
    block_max_position *= occumap.spacing;

    // make occupied block bigger by a voxel to include boundary voxels that are
    // also occupied due to the linear filtering in the volume texture
    block_min_position -= volume.spacing;
    block_max_position += volume.spacing;

    // compute the distance to get to the start of the occupied block
    trace.skip_distance = intersect_box_max(block_min_position, block_max_position, trace.position, -ray.step_direction);
    // trace.skip_distance += length(volume.spacing);
    trace.skipped_distance -= trace.skip_distance;

    // update trace position
    trace.distance -= trace.skip_distance;
    trace.distance = max(trace.distance, ray.start_distance);
    trace.position = ray.origin_position + ray.step_direction * trace.distance; 
    trace.spanned_distance = trace.distance - ray.box_start_distance;

    // update trace volume texture coordinates
    trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // updata ray start
    ray.start_distance = trace.distance;
    ray.start_position = trace.position;
    ray.span_distance = max(ray.end_distance - ray.start_distance, 0.0);
}
else
{
    // terminate ray
    ray.start_distance = ray.box_end_distance;
    ray.start_position = ray.box_end_position;
    ray.span_distance = 0.0;

    // terminate trace
    trace.distance = ray.box_end_distance;
    trace.position = ray.box_end_position;
    trace.voxel_coords = ivec3(floor(trace.position * volume.inv_spacing));
    trace.voxel_texture_coords = trace.position * volume.inv_size;

    // terminate accumulated distances
    trace.stepped_distance = 0.0;
    trace.spanned_distance = ray.box_span_distance;
    trace.skipped_distance = ray.box_span_distance;
}

