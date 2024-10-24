
occumap.lod = occupancy_lods - 1;
occumap.lod_scale = exp2(float(occumap.lod));
occumap.dimensions = occupancy_base_dimensions / int(occumap.lod_scale);
occumap.spacing = occupancy_base_spacing * occumap.lod_scale;

occumap.max_skips = mmax(occumap.dimensions);
occumap.max_skips = min(occumap.max_skips, occupancy_max_skips);

occumap.offset.y = occupancy_base_dimensions.y - 2 * occumap.dimensions.y;
occumap.offset.z = occupancy_base_dimensions.z;
if (occumap.lod == 0) occumap.offset = ivec3(0);


