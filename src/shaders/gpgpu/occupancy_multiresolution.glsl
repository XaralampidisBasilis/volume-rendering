
precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data; // needs to be HalfFloatType
uniform ivec3 u_volume_size;
uniform ivec3 u_block_size;
uniform ivec3 u_occupancy_size;
uniform float u_threshold;

// variable sampler2D u_occupancy_data;

ivec3 pos2to3(in ivec2 pos2, in ivec3 size3);

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coord = ivec2(gl_FragCoord.xy - vec2(0.5));
    ivec3 block_coord = pos2to3(pixel_coord, u_occupancy_size);

    // Get min and max block voxel positions in the volume
    ivec3 block_min = u_block_size * block_coord;
    ivec3 block_max = min(block_min + u_block_size, u_volume_size);
   
    // Scan the volume block to find voxels with value above threshold
    int[64] bits;

    for (int z = block_min.z; z < block_max.z; z++) {
        for (int y = block_min.y; y < block_max.y; y++) {
            for (int x = block_min.x; x < block_max.x; x++) {


                ivec3 voxel_coord = ivec3(x, y, z);
                float voxel_value = texelFetch(u_volume_data, voxel_coord, 0).r;

                ivec3 block_coord = 2 * voxel_coord - block_min - block_max;
                ivec3 block_octant = sign(block_coord);
                ivec3 block_hexacontatetrant = sign(2 * block_coord - u_block_size * block_octant);
                ivec3 block_indices = (3 + 2 * block_octant + block_hexacontatetrant) / 2; // in range [0, 3][0, 3][0, 3]
                int bits = block_indices.x + 4 * block_indices.y + 16 * block_indices.z; // in range [0, 63]

                if (voxel_value > u_threshold) {
                    bitstring |= (1 << bits);
                }
            }
        }
    }
    

    gl_FragColor = vec4(vec4(occupied ? 1.0 : 0.0));
}

ivec3 pos2to3(in ivec2 pos2, in ivec3 size3)
{
    // assuming gl_FragCoord centered at half-voxel
    // pos2 range x in [0, size.x], y in [0, size.y * size.z]
    ivec3 pos3;
    pos3.x = pos2.x;
    pos3.y = pos2.y % size3.y;
    pos3.z = pos2.y / size3.y;

    return pos3;
}
