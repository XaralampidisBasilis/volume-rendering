

occumap.lod = occumaps.atlas_lods - 1;
occumap.lod_scale = exp2(float(occumap.lod));

occumap.dimensions = occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = occumaps.base_spacing * occumap.lod_scale;

occumap.start_coords = ivec3(0);
if (occumap.lod > 0) 
{
    occumap.start_coords.x = 0;
    occumap.start_coords.y = occumaps.base_dimensions.y - 2 * occumap.dimensions.y;
    occumap.start_coords.z = occumaps.base_dimensions.z;
}


