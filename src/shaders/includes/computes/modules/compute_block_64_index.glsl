/**
 * @brief Computes the linear index of a 64-block in a 4x4x4 grid based on voxel coordinates.
 *
 * This function calculates the index of a specific block within an octree structure,
 * mapping voxel coordinates to a 4x4x4 grid (total 64 blocks). The index is determined
 * by computing relative positions and signs within the octree hierarchy.
 *
 * @param block_min_voxel_coords Minimum voxel coordinates of the block.
 * @param block_max_voxel_coords Maximum voxel coordinates of the block.
 * @param voxel_coords Coordinates of the voxel within the block.
 * @return The linear index of the 64-block in the 4x4x4 grid (range [0, 63]).
 */
int compute_block_64_index
(
    in uniforms_computation u_computation,
    in ivec3 block_min_voxel_coords, 
    in ivec3 block_max_voxel_coords, 
    in ivec3 voxel_coords
)
{   
    // Compute coordinates relative to the block center.
    ivec3 octant_coords = 2 * voxel_coords - block_min_voxel_coords - block_max_voxel_coords;

    // Compute the sign of the octant that the voxel is inside.
    ivec3 octant_sign = compute_sign(octant_coords);

    // Compute coordinates relative to the current octant block center.
    ivec3 suboctant_coords = 2 * octant_coords - u_computation.block_dimensions * octant_sign;

    // Compute the sign of the suboctant of the octant block that the voxel is inside.
    ivec3 suboctant_sign = compute_sign(suboctant_coords);

    // Compute coordinates of the 64-block in the 4x4x4 grid (range [0, 3][0, 3][0, 3]).
    ivec3 block_64_coords = (3 + 2 * octant_sign + suboctant_sign) / 2;

    // Compute the linear index of the 64-block in the 4x4x4 grid (range [0, 63]).
    int block_64_index = block_64_coords.x + 4 * block_64_coords.y + 16 * block_64_coords.z;   

    return block_64_index;
}
