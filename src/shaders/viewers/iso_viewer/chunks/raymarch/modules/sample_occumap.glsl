
block.coords = ivec3(trace.position / occumap.spacing);
block.occupied = texelFetch(u_sampler.occumaps, occumap.offset + block.coords, 0).r > 0.0;

// compute block min and max positions in space
block.min_position = vec3(block.coords) * occumap.spacing;
block.max_position = block.min_position + occumap.spacing;

// intersect ray with block to find the skipping distance
block.skipping = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction);
block.skipping += length(occumap.spacing) * MILLI_TOL; // add small values to avoid numerical instabilities in block boundaries

