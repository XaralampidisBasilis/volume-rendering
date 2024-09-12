
int find_octree_block(ivec3 block_min, ivec3 block_max, ivec3 voxel_pos)
{   
    // compute position relative to the block center
    ivec3 relative_pos = 2 * voxel_pos - block_min - block_max;

    // compute the sign of the octant that relative_pos is inside
    ivec3 octant_sign = sign_nonzero(relative_pos);

    // compute position relative to the current octant block center
    ivec3 suboctant_pos = 2 * relative_pos - u_block_size * octant_sign;

    // compute the sign of the suboctant of the octant block that voxel_pos is inside
    ivec3 suboctant_sign = sign_nonzero(suboctant_pos);

    // compute position in a 4x4x4 block grid
    ivec3 hexacontatetrant_pos = (3 + 2 * octant_sign + suboctant_sign) / 2; // in range [0, 3][0, 3][0, 3]

    // compute the linear position in the 4x4x4 block grid
    int hexacontatetra_index = hexacontatetrant_pos.x + 4 * hexacontatetrant_pos.y + 16 * hexacontatetrant_pos.z; // in range [0, 63]   

    return hexacontatetra_index;
}