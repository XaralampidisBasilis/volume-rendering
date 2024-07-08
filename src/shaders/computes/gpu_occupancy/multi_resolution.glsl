
precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data; // needs to be HalfFloatType
uniform ivec3 u_volume_size;
uniform ivec3 u_block_size;
uniform ivec3 u_occupancy_size;
uniform float u_threshold;

// variable sampler2D v_compute_data;

#include ../../includes/utils/reshape_coordinates.glsl;

int find_octree_block(ivec3 block_min, ivec3 block_max, ivec3 voxel_pos);
ivec3 sign_nonzero(ivec3 position);

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_pos = ivec2(gl_FragCoord.xy); // gl_FragColor = vec4(vec2(pixel_coord) / vec2(u_occupancy_size.x-1, u_occupancy_size.y * u_occupancy_size.z-1), 1.0, 1.0);
    ivec3 block_pos = reshape_2d_to_3d(pixel_pos, u_occupancy_size); // gl_FragColor = vec4(vec3(block_coord)/vec3(u_occupancy_size-1), 1.0);

    // Get min and max block voxel positions in the volume
    ivec3 block_min = max(u_block_size * block_pos, 0); // gl_FragColor = vec4((vec3(voxel_min)/vec3(u_volume_size-1)), 1.0);
    ivec3 block_max = min(block_min + u_block_size, u_volume_size) - 1; // gl_FragColor = vec4((vec3(voxel_max)/vec3(u_volume_size-1)), 1.0);

    // initialize bounding box
    ivec3 bb_min = block_max;
    ivec3 bb_max = block_min;
    int[64] occupancy;

    for (int i = 0; i < 64; ++i) {
        occupancy[i] = 0;
    }
    
    // Scan the volume block to find voxels with value above threshold
    for (int z = block_min.z; z <= block_max.z; z++) {
        for (int y = block_min.y; y <= block_max.y; y++) {
            for (int x = block_min.x; x <= block_max.x; x++) {

                ivec3 voxel_pos = ivec3(x, y, z);
                float voxel_value = texelFetch(u_volume_data, voxel_pos, 0).r;

                if (voxel_value > u_threshold) 
                {
                    // update bounding box
                    bb_min = min(bb_min, voxel_pos);
                    bb_max = max(bb_max, voxel_pos);

                    // compute occupancy index
                    int n = find_octree_block(block_min, block_max, voxel_pos);
                    occupancy[n] = 1;
                }
            }
        }
    }

    // encode data with color
    ivec4 color_data = ivec4(0);

    // convert occupancy array to colors
    for (int i = 31; i >=  0; i--) color_data.r = (color_data.r << 1) | occupancy[i];
    for (int i = 63; i >= 32; i--) color_data.g = (color_data.g << 1) | occupancy[i];
    
    // encode block bounding box
    color_data.b = reshape_3d_to_1d(bb_min, u_volume_size);
    color_data.a = reshape_3d_to_1d(bb_max, u_volume_size);

    // write color data
    gl_FragColor = intBitsToFloat(color_data);
}

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

ivec3 sign_nonzero(ivec3 position)
{
    return 2 * ivec3(lessThan(ivec3(0), position)) - 1;
}