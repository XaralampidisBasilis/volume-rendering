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
    ivec3 voxel_min = max(u_block_size * block_coord, 0);
    ivec3 voxel_max = min(voxel_min + u_block_size, u_volume_size);

    // Scan the volume block to find voxels with value above threshold
    int occupied = 0; 
    ivec3 bb_min = voxel_max;
    ivec3 bb_max = voxel_min;

    for (int z = voxel_min.z; z < voxel_max.z; z++) {
        for (int y = voxel_min.y; y < voxel_max.y; y++) {
            for (int x = voxel_min.x; x < voxel_max.x; x++) {

                ivec3 voxel_coord = ivec3(x, y, z);
                float voxel_value = texelFetch(u_volume_data, voxel_coord, 0).r;

                if (voxel_value > u_threshold) {
                    bb_min = min(bb_min, voxel_coord);
                    bb_max = max(bb_max, voxel_coord);
                    occupied = 1;
                }
            }
        }
    }

    // encode block bounding box as float
    float num_voxels = float(u_volume_size.x * u_volume_size.y * u_volume_size.z);
    float bbi_min = float(reshape_3d_to_1d(bb_min, u_volume_size)) / num_voxels; 
    float bbi_max = float(reshape_3d_to_1d(bb_max, u_volume_size)) / num_voxels;

    // needs to be THREE.FloatType
    gl_FragColor = vec4(bbi_min, bbi_max, 0.0, occupied);
}
