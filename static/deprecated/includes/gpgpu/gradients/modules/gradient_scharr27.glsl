/**
 * Calculates the gradient and the smoothed sample at a given position in 
 * a 3D texture using the Scharr operator and smoothing.
 *
 * @param volume_data: 3D texture sampler containing intensity data. Assumes LinearFilter & ClampToEdgeWrapping in texture
 * @param volume_spacing: Spacing between voxels in the 3D texture.
 * @param volume_dimensions: Dimensions of the 3D texture.
 * @param voxel_coords: Coordinates of the voxel in the 3D texture.
 *
 * @return vec4: Gradient vector at the given position as rgb and smoothed sample as alpha.
 */

vec4 gradient_scharr27
(
    in sampler3D volume_data, 
    in vec3 volume_spacing,
    in ivec3 volume_dimensions,
    in ivec3 voxel_coords
)
{
    // Scharr kernels for the X, Y, and Z directions
    const float[27] kernel_x = float[27]
    (
          -3.0,   -10.0,   -3.0,
         -10.0,   -30.0,  -10.0,
          -3.0,   -10.0,   -3.0,
           0.0,    0.0,   0.0,
          0.0,    0.0,   0.0,
          0.0,    0.0,   0.0,
         +3.0,  +10.0,  +3.0,
        +10.0,  +30.0, +10.0,
         +3.0,  +10.0,  +3.0
    );

    const float[27] kernel_y = float[27]
    (
          -3.0,   -10.0,   -3.0,
           0.0,     0.0,    0.0,
          +3.0,   +10.0,   +3.0,
         -10.0,  -30.0, -10.0,
          0.0,    0.0,   0.0,
        +10.0,  +30.0, +10.0,
         -3.0,  -10.0,  -3.0,
          0.0,    0.0,   0.0,
         +3.0,  +10.0,  +3.0
    );

    const float[27] kernel_z = float[27]
    (
          -3.0,    0.0,    +3.0,
         -10.0,    0.0,   +10.0,
          -3.0,    0.0,    +3.0,
         -10.0,   0.0,  +10.0,
        -30.0,   0.0,  +30.0,
        -10.0,   0.0,  +10.0,
         -3.0,   0.0,   +3.0,
        -10.0,   0.0,  +10.0,
         -3.0,   0.0,   +3.0
    );

    // Define offsets for the 27 neighboring samples 
    const vec3 k = vec3(-1.0, 0.0, +1.0);
    const vec3[27] samples_offset = vec3[27]
    (
         k.xxx,   k.xxy,   k.xxz,  
         k.xyx,   k.xyy,   k.xyz,  
         k.xzx,   k.xzy,   k.xzz,
         k.yxx,  k.yxy,  k.yxz, 
        k.yyx,  k.yyy,  k.yyz,
        k.yzx,  k.yzy,  k.yzz,
        k.zxx,  k.zxy,  k.zxz, 
        k.zyx,  k.zyy,  k.zyz, 
        k.zzx,  k.zzy,  k.zzz
    );

    // Calculate the position and step sizes within the 3D texture
    vec3 voxel_step = 1.0 / vec3(volume_dimensions);
    vec3 voxel_pos = (vec3(voxel_coords) + 0.5) * voxel_step;
    
    // Sample values at the neighboring points
    float samples[27];
    for (int i = 0; i < 27; i++)
    {
        vec3 sample_pos = voxel_pos + voxel_step * samples_offset[i];
        samples[i] = texture(volume_data, sample_pos).r;
        samples[i] *= inside_box(0.0, 1.0, sample_pos);
    }

    // Calculate the gradient based on the sampled values using the Sobel operator
    vec3 gradient = vec3(0.0);
    for (int i = 0; i < 27; i++)
    {
        gradient.x += kernel_x[i] * samples[i];
        gradient.y += kernel_y[i] * samples[i];
        gradient.z += kernel_z[i] * samples[i];
    }
    // Normalize the kernel values
    gradient /= 82.0;
    
    // Adjust gradient to physical space 
    gradient /= 2.0 * volume_spacing;

    // Combine results
    return vec4(normalize(gradient), length(gradient));
}
