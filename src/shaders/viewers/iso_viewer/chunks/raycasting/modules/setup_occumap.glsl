

// start at the coarsest level of detail available
occumap.lod = u_raymarch.max_skip_lod;
occumap.lod_scale = floor(exp2(float(occumap.lod)));

// compute occumap parameters
occumap.dimensions = u_occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = u_occumaps.base_spacing * occumap.lod_scale;

// compute occumap start texture coordinates inside occumaps atlas
occumap.start_coords.y = u_occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
occumap.start_coords.z = u_occumaps.base_dimensions.z;
if (occumap.lod == 0) occumap.start_coords = ivec3(0);
