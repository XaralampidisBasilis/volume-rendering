precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data;
uniform ivec3 u_volume_size;
uniform ivec3 u_occupancy_size;
uniform ivec3 u_block_size;
uniform float u_threshold;

// variable sampler2D u_occupancy_data;

#include ../../includes/utils/reshape_coordinates.glsl;
#include ../../includes/utils/product.glsl;

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coord = ivec2(floor(gl_FragCoord.xy)); // gl_FragColor = vec4(vec2(pixel_coord) / vec2(u_occupancy_size.x-1, u_occupancy_size.y * u_occupancy_size.z-1), 1.0, 1.0);
    ivec3 block_coord = reshape_2d_to_3d(pixel_coord, u_occupancy_size); // gl_FragColor = vec4(vec3(block_coord)/vec3(u_occupancy_size-1), 1.0);

    // Get min and max block voxel positions in the volume
    ivec3 voxel_min = max(u_block_size * block_coord, 0); // gl_FragColor = vec4((vec3(voxel_min)/vec3(u_volume_size-1)), 1.0);
    ivec3 voxel_max = min(voxel_min + u_block_size, u_volume_size); // gl_FragColor = vec4((vec3(voxel_max)/vec3(u_volume_size-1)), 1.0);

    // Scan the volume block to find voxels with value above threshold
    int occupied = 0; 
    ivec3 bb_min = voxel_max;
    ivec3 bb_max = voxel_min;

    for (int z = voxel_min.z; z <= voxel_max.z; z++) {
        for (int y = voxel_min.y; y <= voxel_max.y; y++) {
            for (int x = voxel_min.x; x <= voxel_max.x; x++) {

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

    // gl_FragColor = vec4(vec3(float(abs(product(bb_max - bb_min)))/float(product(u_block_size))), occupied);

    // encode block bounding box as float
    float normalize = float(u_volume_size.x * u_volume_size.y * u_volume_size.z);
    float bbi_min = float(reshape_3d_to_1d(bb_min, u_volume_size)) / normalize; 
    float bbi_max = float(reshape_3d_to_1d(bb_max, u_volume_size)) / normalize;

    /* debug
    ivec3 bb_min_2 = reshape_1d_to_3d(int(bbi_min * normalize), u_volume_size);
    ivec3 bb_max_2 = reshape_1d_to_3d(int(bbi_max * normalize), u_volume_size);
    gl_FragColor = vec4(vec3(float(abs(product(bb_max_2 - bb_min_2)))/float(product(u_block_size))), occupied);
    return;
    */
    
    // needs to be THREE.FloatType
    gl_FragColor = vec4(bbi_min, bbi_max, 0.0, occupied);
}
