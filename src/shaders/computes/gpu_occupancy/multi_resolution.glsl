
precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data; // needs to be HalfFloatType
uniform ivec3 u_volume_size;
uniform ivec3 u_block_size;
uniform ivec3 u_occupancy_size;
uniform float u_threshold;

// variable sampler2D u_occupancy_data;

#include ../../includes/utils/reshape_coordinates.glsl;

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coord = ivec2(floor(gl_FragCoord.xy)); // gl_FragColor = vec4(vec2(pixel_coord) / vec2(u_occupancy_size.x-1, u_occupancy_size.y * u_occupancy_size.z-1), 1.0, 1.0);
    ivec3 block_coord = reshape_2d_to_3d(pixel_coord, u_occupancy_size); // gl_FragColor = vec4(vec3(block_coord)/vec3(u_occupancy_size-1), 1.0);

    // Get min and max block voxel positions in the volume
    ivec3 voxel_min = max(u_block_size * block_coord, 0); // gl_FragColor = vec4((vec3(voxel_min)/vec3(u_volume_size-1)), 1.0);
    ivec3 voxel_max = min(voxel_min + u_block_size, u_volume_size); // gl_FragColor = vec4((vec3(voxel_max)/vec3(u_volume_size-1)), 1.0);

    // Scan the volume block to find voxels with value above threshold
    uint[64] occupancy;
    for (int i = 0; i < 64; ++i) {
        occupancy[i] = uint(0);
    }

    for (int z = voxel_min.z; z < voxel_max.z; z++) {
        for (int y = voxel_min.y; y < voxel_max.y; y++) {
            for (int x = voxel_min.x; x < voxel_max.x; x++) {

                ivec3 voxel_pos = ivec3(x, y, z);
                float voxel_value = texelFetch(u_volume_data, voxel_pos, 0).r;

                // compute sub block occupancy
                voxel_pos = 2 * voxel_pos - voxel_min - voxel_max;

                ivec3 octant_sign = sign(voxel_pos);
                ivec3 hexacontatetrant_sign = sign(2 * voxel_pos - u_block_size * octant_sign);

                ivec3 hexacontatetrant_pos = (3 + 2 * octant_sign + hexacontatetrant_sign) / 2; // in range [0, 3][0, 3][0, 3]
                int hexacontatetrant_index = hexacontatetrant_pos.x + 4 * hexacontatetrant_pos.y + 16 * hexacontatetrant_pos.z; // in range [0, 63]

                if (voxel_value > u_threshold) 
                {
                    occupancy[hexacontatetrant_index] = uint(1);
                }
            }
        }
    }
    
    // convert occupancy array to colors
    uint red_bitstring = uint(0);
    uint green_bitstring = uint(0);
    uint blue_bitstring = uint(0);
    uint alpha_bitstring = uint(0);

    for (int i = 0; i < 32; i++)
    {
        red_bitstring <<= 1; // Shift left to make space for the new variable
        red_bitstring |= occupancy[i];
    }

    for (int i = 32; i < 64; i++)
    {
        green_bitstring <<= 1; // Shift left to make space for the new variable
        green_bitstring |= occupancy[i];
    }

    // write color data
    gl_FragColor = vec4(uintBitsToFloat(red_bitstring), uintBitsToFloat(green_bitstring), 0.0, 1.0);
}
