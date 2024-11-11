
// get into one level of detail lower
occumap.lod = max(u_raymarch.max_skip_lod, occumap.lod - 1);
occumap.lod_scale = floor(exp2(float(occumap.lod)));

// compute current occumap parameters
occumap.dimensions = u_occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = u_occumaps.base_spacing * occumap.lod_scale;
occumap.inv_dimensions = 1.0 / vec3(occumap.dimensions); 
occumap.inv_spacing = 1.0 / occumap.spacing; 

// compute occumap start texture coordinates inside occumaps atlas
occumap.start_coords.y = u_occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
occumap.start_coords.z = u_occumaps.base_dimensions.z;
if (occumap.lod == 0) occumap.start_coords = ivec3(0);

// compute occumap start texture coordinates inside occumaps atlas
occumap.start_texture_coords = vec3(occumap.start_coords) * u_occumaps.inv_dimensions;
