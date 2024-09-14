
// normalize ray spacing to the range [0, 1]
float max_voxel_spacing = length(u_volume.spacing);
float ray_spacing_norm = ray.spacing / max_voxel_spacing;

debug.ray_spacing = vec4(vec3(ray_spacing_norm), 1.0);
