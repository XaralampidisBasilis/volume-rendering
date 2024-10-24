// compute occupied block min and max positions in space
block.min_position = vec3(block.coords) * occumap.spacing;
block.max_position = block.min_position + occumap.spacing;

// take backstep to get in the start of the occupied block
trace.spacing = intersect_box_max(block.min_position, block.max_position, trace.position, -ray.direction);

// due to linear filtering of the volume texture there are values where 
// occupancy is one even when occupancy is zero. So i need to take that into account
trace.spacing += length(volume_spacing) * 2.0; 

// update trace spatial data
trace.skipped -= trace.spacing;
trace.distance -= trace.spacing;   
trace.distance = max(trace.distance, ray.min_distance);
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * volume_inv_size;
trace.coords = floor(trace.position * volume_inv_spacing);
trace.depth = 0.0;

// update ray spatial data
ray.min_distance = trace.distance;
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);
