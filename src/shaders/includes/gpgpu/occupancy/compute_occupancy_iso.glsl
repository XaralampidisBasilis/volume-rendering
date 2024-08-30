
precision highp int;
precision highp float;
precision highp sampler3D; 

uniform float threshold;
uniform sampler3D volume_data;
uniform ivec3 volume_dimensions;     
uniform ivec3 block_dimensions;
uniform ivec3 occumap_dimensions;
uniform ivec2 computation_dimensions;

#include "../../utils/reshape_coordinates"

void main()
{
    // gl_FragColor = vec4(vec3(volume_dimensions), 1.0); return;
    // gl_FragColor = vec4(vec3(block_dimensions), 1.0); return;
    // gl_FragColor = vec4(vec3(occumap_dimensions), 1.0); return;
    // gl_FragColor = vec4(vec2(computation_dimensions), 1.0 1.0); return;

    // get 2D pixel position of occlusion man and convert it to 3D position
    ivec2 pixel_coords = ivec2(gl_FragCoord.xy); // in range [0, Ox-1][0, Oy*Oz-1]
    ivec3 block_coords = reshape_2d_to_3d(pixel_coords, occumap_dimensions); // in range [0, Ox-1][0, Oy-1][0, Oz-1]

    // gl_FragColor = vec4(vec2(pixel_coords)/vec2(computation_dimensions-1), 1.0, 1.0); return;
    // gl_FragColor = vec4(vec3(block_coords)/vec3(occumap_dimensions-1), 1.0); return;

    // Get min and max block voxel positions in the volume
    ivec3 block_min_voxel_coords = block_coords * block_dimensions; 
    ivec3 block_max_voxel_coords = block_min_voxel_coords + block_dimensions - 1; 

    block_max_voxel_coords = max(block_max_voxel_coords, 0);
    block_max_voxel_coords = min(block_max_voxel_coords, volume_dimensions - 1);

    // gl_FragColor = vec4((vec3(block_voxel_min)/vec3(volume_dimensions-1)), 1.0);   
    // gl_FragColor = vec4((vec3(block_voxel_max)/vec3(volume_dimensions-1)), 1.0);

    // set occumap_dimensions bounding box
    ivec3 bblock_min_voxel_coords = volume_dimensions - 1; // if i remove -1 then bblock min is not computed correcly somehow
    ivec3 bblock_max_voxel_coords = ivec3(0);
    int occupancy = 0;
    
    // Scan the volume block to find voxels with value above threshold
    for (int z = block_min_voxel_coords.z; z <= block_max_voxel_coords.z; z++) 
    {
        for (int y = block_min_voxel_coords.y; y <= block_max_voxel_coords.y; y++) 
        {
            for (int x = block_min_voxel_coords.x; x <= block_max_voxel_coords.x; x++) 
            {
                ivec3 voxel_coords = ivec3(x, y, z);
                float voxel_sample = texelFetch(volume_data, voxel_coords, 0).r;

                // if sample is above threshold update occupancy data
                if (voxel_sample > threshold) 
                {
                    // update bounding box
                    bblock_min_voxel_coords = min(bblock_min_voxel_coords, voxel_coords);
                    bblock_max_voxel_coords = max(bblock_max_voxel_coords, voxel_coords);
                    occupancy++;
                }
            }
        }
    }

    // gl_FragColor = vec4(vec3(bblock_min_voxel_coords)/vec3(volume_dimensions-1), 1.0); return;
    // gl_FragColor = vec4(vec3(bblock_max_voxel_coords)/vec3(volume_dimensions-1), 1.0); return;
    // gl_FragColor = vec4(vec3(bblock_max_voxel_coords - bblock_min_voxel_coords)/vec3(block_dimensions-1), 1.0); return;
    // gl_FragColor = vec4(vec3(occupancy)/vec3(block_dimensions.x * block_dimensions.y * block_dimensions.z), 1.0); return;
    // gl_FragColor = vec4(vec3(occupancy > 0), 1.0); return;

    // encode data with color
    uvec4 color_data = uvec4(0);

    // convert occupancy array to colors
    color_data.r = uint(occupancy);

    // encode block bounding box
    color_data.b = uint(reshape_3d_to_1d(bblock_min_voxel_coords, volume_dimensions));
    color_data.a = uint(reshape_3d_to_1d(bblock_max_voxel_coords, volume_dimensions));

    // write color data
    gl_FragColor = uintBitsToFloat(color_data);

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
