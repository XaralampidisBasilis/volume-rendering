precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data;
uniform ivec3 u_volume_size;
uniform ivec3 u_block_size;
uniform ivec3 u_occupancy_size;
uniform float u_threshold;

// variable sampler2D u_occupancy_data;

#include ../../includes/utils/reshape_coordinates.glsl;

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coord = ivec2(gl_FragCoord.xy);
    ivec3 block_coord = reshape_2d_to_3d(pixel_coord, u_occupancy_size);

    // Get min and max block voxel positions in the volume
    ivec3 voxel_min = u_block_size * block_coord;
    ivec3 voxel_max = min(voxel_min + u_block_size, u_volume_size);

    // Scan the volume block to find voxels with value above threshold
    int occupied = 0; 
    ivec3 bbvoxel_min = voxel_max;
    ivec3 bbvoxel_max = voxel_min;

    for (int z = voxel_min.z; z < voxel_max.z; z++) {
        for (int y = voxel_min.y; y < voxel_max.y; y++) {
            for (int x = voxel_min.x; x < voxel_max.x; x++) {

                ivec3 voxel_coord = ivec3(x, y, z);
                float voxel_value = texelFetch(u_volume_data, voxel_coord, 0).r;

                if (voxel_value > u_threshold) {

                    occupied = 1;
                    bbvoxel_min = max(bbvoxel_min, voxel_coord);
                    bbvoxel_max = min(bbvoxel_max, voxel_coord);
                }
            }
        }
    }

    // encode block bounding box as float
    float bbindex_min = intBitsToFloat(reshape_3d_to_1d(bbvoxel_min, u_volume_size)); 
    float bbindex_max = intBitsToFloat(reshape_3d_to_1d(bbvoxel_max, u_volume_size));

    // normalize linear indexes
    float num_voxels = float(u_volume_size.x * u_volume_size.y * u_volume_size.z);
    bbindex_min /= num_voxels;
    bbindex_max /= num_voxels;

    // needs to be THREE.FloatType
    gl_FragColor = vec4(bbindex_min, bbindex_max, 0.0, occupied);
}
