
vec3 debug_voxel_texture_coords = voxel.texture_coords * u_volume.inv_dimensions;

debug.voxel_texture_coords = vec4(debug_voxel_texture_coords, 1.0);