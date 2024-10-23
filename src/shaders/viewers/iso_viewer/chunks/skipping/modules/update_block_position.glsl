
// compute block min and max positions in space
block.min_position = vec3(block.coords) * occumap.spacing;
block.max_position = block.min_position + occumap.spacing;

// add small values to avoid numerical instabilities in block boundaries
block.min_position -= occumap.spacing * MILLI_TOL;  
block.max_position += occumap.spacing * MILLI_TOL;  

// intersect ray with block to find the skipping distance
block.skipping = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction);
trace.skipped += block.skipping;

// update trace spatial data
trace.spacing = block.skipping;
trace.distance += trace.spacing;
trace.position += ray.direction * trace.spacing;
trace.texel = trace.position * volume_inv_size;
trace.depth = trace.distance - ray.min_distance;
trace.coords = floor(trace.position * volume_inv_spacing);
