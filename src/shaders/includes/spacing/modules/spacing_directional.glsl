
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
    // Area of the orthographic projection of the voxel cube faces in the ray_direction
    vec3 projected_voxel_faces = volume_spacing * volume_spacing.yzx * abs(ray_direction.zxy);  

    // Total area of the orthographic projection of the voxel cube in the ray_direction
    float projected_voxel_area = sum(projected_voxel_faces); 

    // the total volume of the voxel cube
    float voxel_volume = prod(volume_spacing); 

    // Average spacing of the ray-voxel cube intersection
    float ray_spacing = voxel_volume / stabilize(projected_voxel_area);

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
    // Area of the orthographic projection of the voxel cube faces in the ray_direction (when profile is 1)
    vec3 projected_voxel_faces = pow(volume_spacing * volume_spacing.yzx * abs(ray_direction.zxy), vec3(profile));  

    // Total area of the orthographic projection of the voxel cube in the ray_direction (when profile is 1)
    float projected_voxel_area = pow(sum(projected_voxel_faces), 1.0 / profile); 

    // the total volume of the voxel cube
    float voxel_volume = prod(volume_spacing); 

    // Average spacing of the ray-voxel cube intersection (when profile is 1)
    float ray_spacing = voxel_volume / projected_voxel_area;

    return ray_spacing;
}
