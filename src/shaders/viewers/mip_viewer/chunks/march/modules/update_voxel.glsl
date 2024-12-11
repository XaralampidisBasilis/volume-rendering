
// update position
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
vec4 taylormap_texture_sample = texture(u_textures.taylor_map, voxel.texture_coords);

// update value and gradient
voxel.value = taylormap_texture_sample.r;
voxel.gradient = taylormap_texture_sample.gba;
voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

// update projection
if (voxel.value > proj_voxel.value) 
{
    proj_voxel = voxel;
    proj_trace = trace;
}