
// get into one level of detail lower
occumap.lod -= 1;
occumap.lod_scale = floor(exp2(float(occumap.lod)));

// compute current occumap parameters
occumap.dimensions = occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = occumaps.base_spacing * occumap.lod_scale;

// compute occumap start texture coordinates inside occumaps atlas
occumap.start_coords.y = occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
occumap.start_coords.z = occumaps.base_dimensions.z;
if (occumap.lod == 0) occumap.start_coords = ivec3(0);

