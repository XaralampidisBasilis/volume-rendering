// gradient_sobel8

/**
 * Calculates the gradient and the smoothed sample at a given position in 
 * a 3D texture using trilinear interpolation sobel operator and smoothing
 * https://github.com/neurolabusc/blog/blob/main/GL-gradients/README.md
 *
 * @param volume_data: 3D texture sampler containing intensity data.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha
 */

// sample neighbors
float values[8];
vec3 texture_coords = trace.voxel_texels - u_volume.inv_dimensions * 0.5;

#pragma unroll_loop_start
for (int i = 0; i < 8; i++) {
    values[i] = textureOffset(u_textures.taylor_map, texture_coords, binary_offsets[i]).r;
}
#pragma unroll_loop_end

// compute gradient
voxel.gradient = vec3(
    values[1] + values[5] + values[6] + values[7] - values[0] - values[3] - values[2] - values[4],
    values[2] + values[4] + values[6] + values[7] - values[0] - values[3] - values[1] - values[5],
    values[3] + values[4] + values[5] + values[7] - values[0] - values[2] - values[1] - values[6]
);
voxel.gradient *= u_volume.inv_spacing * 0.25;