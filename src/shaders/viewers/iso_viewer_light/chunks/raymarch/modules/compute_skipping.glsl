
ivec3 base_dimensions = u_occupancy.base_dimensions;
float spacing_delta = ray.spacing;

block.lod = u_occupancy.lods - 1;
float scaling = exp2(float(block.lod));
ivec3 occumap_dimensions = base_dimensions / int(scaling);
block.size = u_occupancy.base_spacing * scaling;

ivec3 occumap_offset = ivec3(0);
if (block.lod > 0) 
{
    occumap_offset.y = base_dimensions.y - 2 * occumap_dimensions.y;
    occumap_offset.z = base_dimensions.z;
}

for (int steps = 1; steps < MAX_SKIPPING_STEPS && trace.distance < ray.max_distance; steps++) 
{
    // Calculate block coordinates and occupancy
    block.coords = ivec3(trace.position / block.size);
    float occupancy = texelFetch(u_sampler.occumaps, block.coords + occumap_offset, 0).r;
    block.occupied = occupancy > 0.0;

    if (!block.occupied) 
    {
        #include "./skip_block"
        continue;
    } 
    else 
    {
        if (block.lod == 0) break; 
        block.lod--;
        block.size *= 0.5;
        occumap_dimensions *= 2;
        occumap_offset.y = (block.lod > 0) ? base_dimensions.y - 2 * occumap_dimensions.y : 0;
        occumap_offset.z = (block.lod > 0) ? base_dimensions.z : 0;
    }
}

trace.spacing = - spacing_delta * 2.0;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * u_volume.inv_size;