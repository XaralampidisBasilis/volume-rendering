/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray bounds
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @param ray_bounds: Vector containing the start and end distances of the ray within the volume (in normalized coordinates)
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 stride(in raycast_uniforms u_raycast, in volume_uniforms u_volume, in vec3 ray_normal, in vec2 ray_bounds) 
{
    // Find the maximum dimension of the volume to ensure proper scaling
    float dimension_max = max(u_volume.dimensions.x, max(u_volume.dimensions.y, u_volume.dimensions.z));
    
    // Calculate the total distance the ray will travel within the volume
    float ray_span = ray_bounds.y - ray_bounds.x;
    
    // Determine the number of steps the ray should take, based on the resolution and maximum dimension
    float ray_steps = ceil(ray_span * dimension_max * u_raycast.resolution);
    
    // Calculate the distance covered in each step
    float ray_delta = ray_span / ray_steps;

    // Clamp ray delta to a min value
    ray_delta = max(ray_delta, 0.01 / dimension_max);

    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_delta * ray_normal;
}

/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray normal direction
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 stride_2(in raycast_uniforms u_raycast, in volume_uniforms u_volume, in vec3 ray_normal) 
{
    // compute the voxel box 
    vec3 voxel_min = vec3(0.0);
    vec3 voxel_max = u_volume.voxel;

    // find the ray delta inside the voxel box
    float ray_delta = intersect_box_max(voxel_min, voxel_max, voxel_min, abs(ray_normal));
    ray_delta = ray_delta / u_raycast.resolution;

    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_delta * ray_normal;
}
