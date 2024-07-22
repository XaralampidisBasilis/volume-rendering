
precision highp int;
precision highp float;
precision highp sampler3D; 

#include "./modules/uniforms_computation"
#include "./modules/compute_sign"
#include "./modules/compute_block_64_index"
#include "../../utils/reshape_coordinates"

void main()
{
    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coords = ivec2(gl_FragCoord.xy); // in range [0, Ox-1][0, Oy*Oz-1]
    ivec3 block_coords = reshape_2d_to_3d(pixel_coords, u_computation.occupancy_dimensions); // in range [0, Ox-1][0, Oy-1][0, Oz-1]

    // gl_FragColor = vec4(vec2(pixel_coords)/vec2(u_computation.computation_dimensions-1), 1.0, 1.0);
    // gl_FragColor = vec4(vec3(block_coords)/vec3(u_computation.occupancy_dimensions-1), 1.0);

    // Get min and max block voxel positions in the volume
    ivec3 block_min_voxel_coords = block_coords * u_computation.block_dimensions; 
    ivec3 block_max_voxel_coords = block_min_voxel_coords + u_computation.block_dimensions - 1; 

    // gl_FragColor = vec4((vec3(block_voxel_min)/vec3(u_computation.volume_dimensions-1)), 1.0);   
    // gl_FragColor = vec4((vec3(block_voxel_max)/vec3(u_computation.volume_dimensions-1)), 1.0);

    // set occupancy bounding box
    ivec3 bblock_min_voxel_coords = u_computation.volume_dimensions - 1;
    ivec3 bblock_max_voxel_coords = ivec3(0);
    
    // set occupancy array
    int[64] occupancy_64;

    for (int i = 0; i < 64; ++i) 
        occupancy_64[i] = 0;
    
    // Scan the volume block to find voxels with value above threshold
    for (int z = block_min_voxel_coords.z; z <= block_max_voxel_coords.z; z++) 
    {
        for (int y = block_min_voxel_coords.y; y <= block_max_voxel_coords.y; y++) 
        {
            for (int x = block_min_voxel_coords.x; x <= block_max_voxel_coords.x; x++) 
            {
                ivec3 voxel_coords = ivec3(x, y, z);
                float voxel_sample = texelFetch(u_computation.volume_data, voxel_coords, 0).r;

                // if sample is above threshold update occupancy data
                if (voxel_sample >= u_computation.threshold) 
                {
                    // update bounding box
                    bblock_min_voxel_coords = min(bblock_min_voxel_coords, voxel_coords);
                    bblock_max_voxel_coords = max(bblock_max_voxel_coords, voxel_coords);

                    // compute occupancy index
                    int index = compute_block_64_index(u_computation, block_min_voxel_coords, block_max_voxel_coords, voxel_coords);
                    occupancy_64[index] = 1;
                }
            }
        }
    }

    // gl_FragColor = vec4(vec3(length(vec3(occubox_max_voxel_pos) - vec3(occubox_min_voxel_pos))/length(vec3(u_computation.volume_dimensions))), 1.0);   
    // gl_FragColor = vec4(0.5 * vec3(occubox_max_voxel_pos + occubox_min_voxel_pos) / vec3(u_computation.volume_dimensions), 1.0);   

    // encode data with color
    uvec4 color_data = uvec4(0);

    // convert occupancy array to colors
    for (int i = 31; i >=  0; i--) color_data.r = (color_data.r << 1) | uint(occupancy_64[i]);
    for (int i = 63; i >= 32; i--) color_data.g = (color_data.g << 1) | uint(occupancy_64[i]);
    
    // encode block bounding box
    color_data.b = uint(reshape_3d_to_1d(bblock_min_voxel_coords, u_computation.volume_dimensions));
    color_data.a = uint(reshape_3d_to_1d(bblock_max_voxel_coords, u_computation.volume_dimensions));

    // write color data
    gl_FragColor = uintBitsToFloat(color_data);
}
