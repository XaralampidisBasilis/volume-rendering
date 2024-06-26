
precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data;
uniform ivec3 u_volume_size;
uniform ivec3 u_block_size;
uniform ivec3 u_occupancy_size;
uniform float u_threshold;

// variable sampler2D u_occupancy_data;

#include ../utils/reshape_coordinates.glsl;

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coord = ivec2(gl_FragCoord.xy);
    ivec3 block_coord = reshape_2d_to_3d(pixel_coord, u_occupancy_size);

    // Get min and max block voxel positions in the volume
    ivec3 block_min = u_block_size * block_coord;
    ivec3 block_max = min(block_min + u_block_size, u_volume_size);

    // Scan the volume block to find voxels with value above threshold
    float density = 0.0;

    for (int z = block_min.z; z < block_max.z; z++) {
        for (int y = block_min.y; y < block_max.y; y++) {
            for (int x = block_min.x; x < block_max.x; x++) {

                ivec3 voxel_coord = ivec3(x, y, z);
                float voxel_value = texelFetch(u_volume_data, voxel_coord, 0).r;

                if (voxel_value > u_threshold)
                    density += 1.0;
            }
        }
    }

    float voxels = float(u_block_size.x * u_block_size.y * u_block_size.z);
    density /= voxels;

    bool occupied = (density > 0.001 * u_threshold);

    gl_FragColor = vec4(occupied);
}
