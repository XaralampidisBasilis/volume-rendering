
// compute the adjusted direction by scaling the ray's absolute direction with the inverse spacing of the u_intensity_map.
vec3 directional_spacing = abs(ray.direction) * u_intensity_map.inv_spacing;

// calculate the ray spacing as the mean value of ray depths from all parallel rays intersecting the voxel aabb.
ray.step_distance = 1.0 / sum(directional_spacing);
