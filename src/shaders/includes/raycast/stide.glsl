/**
 * Calculates the stride (step vector) for raycasting through a volume.
 *
 * @param u_raycast: Struct containing raycast-related uniforms.
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray_normal: Normalized direction vector of the ray.
 * @param ray_bounds: Vector containing the start and end distances of the ray within the volume (in normalized coordinates)
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */
vec3 stride(in raycast_uniforms u_raycast, in volume_uniforms u_volume, in vec3 ray_normal, in vec2 ray_bounds) {

    // Find the maximum dimension of the volume to ensure proper scaling
    float dimension_max = max(u_volume.dimensions.x, max(u_volume.dimensions.y, u_volume.dimensions.z));
    
    // Calculate the total distance the ray will travel within the volume
    float distance = ray_bounds.y - ray_bounds.x;
    
    // Determine the number of steps the ray should take, based on the resolution and maximum dimension
    float ray_steps = ceil(distance * dimension_max * u_raycast.resolution);
    
    // Calculate the distance covered in each step
    float ray_delta = distance / ray_steps;
    
    // Return the stride vector by scaling the ray's direction vector by the step distance
    return ray_delta * ray_normal;
}