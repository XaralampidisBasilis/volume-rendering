
// update position
voxel.coords = ivec3(trace.position * u_volume.inv_spacing);
voxel.texture_coords = trace.position * u_volume.inv_size;
vec4 texture_sample = texture(u_textures.taylormap, voxel.texture_coords);

// update value
voxel.value = texture_sample.r;

// update gradient
voxel.gradient = texture_sample.gba;
voxel.gradient = mix(u_volume.min_gradient, u_volume.max_gradient, voxel.gradient);

// update projection
if (voxel.value > proj_voxel.value) 
{
    proj_voxel = voxel;
    proj_trace = trace;
}