
/**
 * Calculates the stride (step vector) for raycasting through a volume considering the ray normal direction
 *
 * @param u_volume: Struct containing volume-related uniforms.
 * @param ray: Struct containing ray parameters (origin, direction, bounds, etc.).
 * @return vec3 The stride vector for stepping through the volume along the ray.
 */

 float spacing_directional
(
    in vec3 volume_spacing, 
    in vec3 ray_direction
) 
{
    vec3 adjusted_direction = abs(ray_direction) / volume_spacing;
    float ray_spacing = 1.0 / sum(adjusted_direction);
    
    return ray_spacing;
}


// Profile factor that changes projected voxel area
// profile > 1 means bigger spacing when near voxel diagonal
// profile < 1 means lower spacing when near voxel diagonal
float spacing_directional
(
    in vec3 volume_spacing, 
    in vec3 ray_direction,
    in float profile
) 
{
    vec3 adjusted_direction = pow(abs(ray_direction) / volume_spacing, vec3(profile));
    float ray_spacing = 1.0 / pow(sum(adjusted_direction), 1.0 / profile);

    return ray_spacing;
}

// depricated due to numerical instability
// float spacing_directional
// (
//     in vec3 volume_spacing, 
//     in vec3 ray_direction
// ) 
// {
//     // Area of the orthographic projection of the voxel cube faces in the ray_direction
//     vec3 projected_voxel_faces = volume_spacing * volume_spacing.yzx * abs(ray_direction.zxy);  

//     // Total area of the orthographic projection of the voxel cube in the ray_direction
//     float projected_voxel_area = sum(projected_voxel_faces); 

//     // the total volume of the voxel cube
//     float voxel_volume = prod(volume_spacing); 

//     // Average spacing of the ray-voxel cube intersection
//     float ray_spacing = voxel_volume / projected_voxel_area;

//     return ray_spacing;
// }