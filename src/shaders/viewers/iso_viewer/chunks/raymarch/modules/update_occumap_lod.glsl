
occumap.lod -= 1;
occumap.lod_scale = exp2(float(occumap.lod));
occumap.dimensions = u_occupancy.base_dimensions / int(occumap.lod_scale);
occumap.spacing = u_occupancy.base_spacing * occumap.lod_scale;

occumap.offset.y = base_dimensions.y - 2 * occumap.dimensions.y;
occumap.offset.z = base_dimensions.z;
if (occumap.lod < 1) occumap.offset = ivec3(0);
