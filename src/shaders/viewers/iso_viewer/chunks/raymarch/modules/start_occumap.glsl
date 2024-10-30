
// start at the coarsest level of the occumaps
occumap.lod = raymarch.min_skip_lod;
occumap.lod_scale = exp2(float(occumap.lod));

// compute occumap dimensions and block spacing
occumap.dimensions = occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = occumaps.base_spacing * occumap.lod_scale;

// compute the occumap start coordinates in the occumaps atlas texture
occumap.start_coords.y = occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
occumap.start_coords.z = occumaps.base_dimensions.z;
if (occumap.lod == 0) occumap.start_coords = ivec3(0);

// coumpute the maximum allowed number of skips based on the current occumap dimensions
ray.max_skip_count = mmax(occumap.dimensions);
ray.max_skip_count = min(ray.max_skip_count, raymarch.max_skip_count);
ray.max_block_distance = length(occumap.spacing);

trace.block_lod = occumap.lod;
