
vec3 debug_proj_voxel_coords = vec3(proj_voxel.coords) * u_volume.inv_dimensions;

debug.proj_voxel_coords = vec4(debug_proj_voxel_coords, 1.0);