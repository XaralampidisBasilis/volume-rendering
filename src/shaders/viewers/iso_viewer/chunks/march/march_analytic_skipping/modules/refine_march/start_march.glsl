
// Compute block coords from trace position
block.coords = ivec3((trace.position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);

// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_distmap.spacing - u_volume.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_distmap.spacing - u_volume.spacing * 0.5;  

// Refine trace position from block entry distance
trace.distance = intersect_box_min(block.min_position, block.max_position, camera.position, ray.step_direction);
trace.distance -= u_volume.spacing_length * 0.5; // safeguard for numerical instabilities
trace.position = camera.position + ray.step_direction * trace.distance; 

// start cell
cell.step_coords = ivec3(0.0);
cell.coords = ivec3(trace.position * u_volume.inv_spacing + 0.5);
cell.bounds.y = trace.distance;
cell.distances.w = trace.distance;
cell.values.w = texture(u_textures.taylor_map, camera.texture_position + ray.texture_direction * cell.distances.w).r;
