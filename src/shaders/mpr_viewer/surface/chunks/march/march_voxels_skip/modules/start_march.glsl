
// start voxel at ray start
voxel.exit_distance = ray.start_distance;
voxel.exit_position = ray.start_position;
voxel.coords = ivec3(voxel.exit_position * u_intensity_map.inv_spacing);
voxel.occupied = int(texelFetch(u_textures.distance_map, voxel.coords, 0).r * 255.0) == 0;
