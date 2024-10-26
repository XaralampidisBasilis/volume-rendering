// update occumap level of detail
occumap.lod -= 1;
occumap.lod_scale = exp2(float(occumap.lod));

// compute occumap dimensions and block spacing
occumap.dimensions = occumaps.base_dimensions / int(occumap.lod_scale);
occumap.spacing = occumaps.base_spacing * occumap.lod_scale;

// compute the occumap start coordinates in the occumaps atlas texture
occumap.start_coords = ivec3(0);
if (occumap.lod > 0) {
    occumap.start_coords.y = occumaps.base_dimensions.y - 2 * occumap.dimensions.y;
    occumap.start_coords.z = occumaps.base_dimensions.z;
}

// compute the max number of skips based on the currect occupam
ray.max_block_distance = length(occumap.spacing);
ray.max_skip_count = mmax(occumap.dimensions);
ray.max_skip_count = min(ray.max_skip_count, raymarch.max_step_count);

