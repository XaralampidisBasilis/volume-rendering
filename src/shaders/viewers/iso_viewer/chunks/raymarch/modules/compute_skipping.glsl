float occupancy_threshold = u_occupancy.threshold;
vec3 inv_volume_size = u_volume.inv_size;
vec3 occumap_size = u_occupancy.occumap_size;

// Start with the coarsest LOD
// int occumap_lod = u_occupancy.occumap_num_lod - 1;
block.lod = int(u_debug.scale);
vec3 occumap_dims = vec3(textureSize(u_sampler.occumap, block.lod).xyz);
block.size = occumap_size / occumap_dims;

for(int counter = 0; counter < u_debug.number; counter++)
{
    block.texel = trace.position / occumap_size;
    block.coords = ivec3(floor(block.texel * occumap_dims));
    block.occupancy = textureLod(u_sampler.occumap, block.texel, float(block.lod)).r;
    // float occupancy = texelFetch(u_sampler.occumap, block.coords, block.lod).r;

    if (block.occupancy <= occupancy_threshold)
    {
       block.min_position = vec3(block.coords) * block.size;
       block.max_position = block.min_position + block.size;
       block.skip_depth = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction);

        trace.spacing = min(block.skip_depth + ray.min_spacing * 0.5, 0.01);
        trace.distance += trace.spacing;
        trace.position += ray.direction * trace.spacing;
        trace.texel = trace.position * inv_volume_size;
        if (trace.distance > ray.max_distance) break;
    }
    else
    {
        break;
        // occumap_lod--;
        // if (occumap_lod == 0) break;

        // occumap_dims = vec3(textureSize(u_sampler.occumap, occumap_lod));
        // block.size = occumap_size / occumap_dims;
    }
}


