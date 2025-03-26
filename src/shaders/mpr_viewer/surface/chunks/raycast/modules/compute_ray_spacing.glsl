
// compute the adjusted direction by scaling the ray's absolute direction with the inverse spacing of the u_volume.
vec3 weights = abs(ray.direction);

// calculate the ray spacing as the mean value of ray depths from all parallel rays intersecting the voxel aabb.
ray.spacing = 1.0 / sum(weights);

