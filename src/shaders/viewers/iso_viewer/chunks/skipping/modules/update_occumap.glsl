
/* Termination condition */

    // cannot update occumap further than the minimum level of detail
    if (occumap.lod == raymarch.min_skip_lod) break;

/* Update occumap */

    // get into one level of detail lower
    occumap.lod -= 1;
    occumap.lod_scale = floor(exp2(float(occumap.lod)));

    // compute current occumap parameters
    occumap.dimensions = occumaps.base_dimensions / int(occumap.lod_scale);
    occumap.spacing = occumaps.base_spacing * occumap.lod_scale;
    occumap.inv_dimensions = 1.0 / vec3(occumap.dimensions);
    occumap.inv_spacing = 1.0 / occumap.spacing;
    occumap.block_dimensions = ivec3(floor(occumap.spacing * volume.inv_spacing));

    // compute current occumap start texture coordinates inside occumaps atlas
    occumap.start_coords = ivec3(0);
    if (occumap.lod > 0)
    {
        occumap.start_coords.y = occumaps.base_dimensions.y  - 2 * occumap.dimensions.y;
        occumap.start_coords.z = occumaps.base_dimensions.z;
        occumap.start_texture_coords = vec3(occumap.start_coords) * occumaps.inv_dimensions;
    }

/* Update ray skip count based on current occumap */

    ray.max_skip_count = mmax(occumap.dimensions);
    ray.max_skip_count = min(ray.max_skip_count, raymarch.max_skip_count);

/* Update trace block level of detail based on current occumap*/

    trace.block_lod = occumap.lod;