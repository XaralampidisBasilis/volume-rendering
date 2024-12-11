
vec3 debug_voxel_coords = vec3(voxel.coords) * u_volume.inv_dimensions;

debug.voxel_coords = vec4(debug_voxel_coords, 1.0);