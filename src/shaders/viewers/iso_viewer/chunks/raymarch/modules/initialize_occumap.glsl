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
