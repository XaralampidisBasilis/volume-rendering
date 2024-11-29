
// Compute block min max coords in distance map
block.min_coords = occumap.block_coords - block.chebyshev_distance + 1;
block.max_coords = occumap.block_coords + block.chebyshev_distance + 0;

// Compute block min max position in model space  
block.min_position = (vec3(block.min_coords) - MILLI_TOLERANCE) * u_distmap.spacing;
block.max_position = (vec3(block.max_coords) + MILLI_TOLERANCE) * u_distmap.spacing;

// intersect ray with block to find end distance and position
ray.end_distance = intersect_box_min(block.min_position, block.max_position, ray.camera_position, ray.step_direction, ray.end_position);
