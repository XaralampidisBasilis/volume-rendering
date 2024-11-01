
// start at the coarsest level of the occumaps
occumap.lod = occumaps.lods - 1;
occumap.lod_scale = floor(exp2(float(occumap.lod)));

// compute occumap dimensions and block spacing
occumap.dimensions = occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = occumaps.base_spacing * occumap.lod_scale;
occumap.inv_dimensions = 1.0 / vec3(occumap.dimensions);
occumap.inv_spacing = 1.0 / occumap.spacing;
occumap.block_dimensions = ivec3(floor(occumap.spacing * volume.inv_spacing));

// compute the occumap start coordinates in the occumaps atlas texture
occumap.start_coords.y = occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
occumap.start_coords.z = occumaps.base_dimensions.z;
if (occumap.lod == 0) occumap.start_coords = ivec3(0);
occumap.start_texture_coords = vec3(occumap.start_coords) * occumaps.inv_dimensions;

// compute the max number of skips based on the currect occumap
ray.max_skip_count = mmax(occumap.dimensions);
ray.max_skip_count = min(ray.max_skip_count, raymarch.max_skip_count);

// update trace block level of detail
trace.block_lod = occumap.lod;