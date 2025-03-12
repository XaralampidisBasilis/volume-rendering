
// compute coordinates 
/*
    Compute stable voxel coordinates by combining the exit position
    with the Chebyshev distance and the exit-face normal. Using only the
    exit position can be numerically unstable on boundary faces, risking
    off-by-one errors between adjacent voxels. This approach corrects
    that axis component to ensure reliable coordinates.
*/
ivec3 coords = voxel.coords + voxel.coords_step * voxel.cheby_distance; 
voxel.coords = ivec3(voxel.exit_position * u_volume.dimensions); 
voxel.coords += abs(voxel.coords_step) * (coords - voxel.coords);

// Compute chebysev distance for empty space skipping
voxel.cheby_distance = int(texelFetch(u_textures.distance_map, voxel.coords, 0).r * 255.0);

// Compute min max coordinates 
ivec3 radius = ivec3(max(0, voxel.cheby_distance - 1));
voxel.min_coords = voxel.coords - radius;
voxel.max_coords = voxel.coords + radius;

// Compute min max positions 
voxel.min_position = vec3(voxel.min_coords + 0) * u_volume.inv_dimensions;
voxel.max_position = vec3(voxel.max_coords + 1) * u_volume.inv_dimensions;  

// compute entry from previous exit, 
voxel.entry_distance = voxel.exit_distance;
voxel.entry_position = voxel.exit_position;

// compute voxel ray intersection to find exit, 
voxel.exit_distance = intersect_box_max(voxel.min_position, voxel.max_position, camera.position, ray.direction, voxel.coords_step);
voxel.exit_position = camera.position + ray.direction * voxel.exit_distance;

// compute break conditions
voxel.intersected = voxel.cheby_distance == 0;
voxel.terminated = voxel.entry_distance > ray.end_distance;

// Update stats
#if STATS_ENABLED == 1
stats.num_fetches += 1;
#endif
