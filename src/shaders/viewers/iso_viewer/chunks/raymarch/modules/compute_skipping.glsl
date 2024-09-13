trace.coords = floor(trace.position * u_volume.inv_spacing);
block.coords = ivec3(trace.coords / u_occupancy.block_dimensions);

// Sample the occupancy map to get occupancy data
vec4 occupancy = step(0.5, texelFetch(u_sampler.occumap, block.coords, 0));
block.resolution = 3.0 - dot(occupancy.gba, vec3(1.0));

// compute block0 min and max voxel coordinates
block.size = u_occupancy.block_dimensions * u_volume.spacing * exp2(block.resolution);
block.min_position = floor(trace.position / block.size) * block.size;
block.max_position = block.min_position + block.size;
    
// intersect ray with block
block.max_depth = intersect_box_max(block.min_position, block.max_position, trace.position, ray.direction); 
block.occupied = occupancy.r > 0.5;

