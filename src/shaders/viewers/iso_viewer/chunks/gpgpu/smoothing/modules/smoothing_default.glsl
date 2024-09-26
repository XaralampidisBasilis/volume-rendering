
vec3 voxel_texel = (vec3(voxel_coords) + 0.5) * volume_inv_dimensions; // we need 0.5 to go to voxel center
float smooth_value = textureLod(volume_data, voxel_texel, 0.0).r;
gl_FragColor = vec4(vec3(smooth_value), 1.0);