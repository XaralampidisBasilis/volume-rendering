// Start with the coarsest LOD
int occumap_lod = u_occupancy.occumap_num_lod - 1;
float occupancy_threshold = u_occupancy.threshold;
vec3 inv_volume_size = u_volume.inv_size;
vec3 occumap_size = u_occupancy.occumap_size;
vec3 occumap_dims = vec3(textureSize(u_sampler.occumap, occumap_lod));
vec3 block_size = occumap_size / occumap_dims;

for(int counter = 0; counter < u_debug.number; counter++)
{
    vec3 block_texel = trace.position / occumap_size;
    ivec3 block_coords = ivec3(floor(block_texel * occumap_dims));
    float occupancy = textureLod(u_sampler.occumap, block_texel, float(occumap_lod)).r;
    // float occupancy = texelFetch(u_sampler.occumap, block_coords, occumap_lod).r;

    if (occupancy <= occupancy_threshold)
    {
        vec3 block_min_position = vec3(block_coords) * block_size;
        vec3 block_max_position = block_min_position + block_size;
        float block_spacing = intersect_box_max(block_min_position, block_max_position, trace.position, ray.direction);

        trace.spacing = block_spacing + ray.min_spacing;
        trace.distance += trace.spacing;
        trace.position += ray.direction * trace.spacing;
        trace.texel = trace.position * inv_volume_size;
        if (trace.distance > ray.max_distance) break;
    }
    else
    {
        occumap_lod--;
        if (occumap_lod == 0) break;

        occumap_dims = vec3(textureSize(u_sampler.occumap, occumap_lod));
        block_size = occumap_size / occumap_dims;
    }
}


