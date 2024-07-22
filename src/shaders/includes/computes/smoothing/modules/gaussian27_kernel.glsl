
const vec3 k = vec3(1.0, 0.0, -1.0);

const vec3[27] gaussian_k_offset = vec3[27]
(
     k.xxx,  k.xxy,  k.xxz,  
     k.xyx,  k.xyy,  k.xyz,  
     k.xzx,  k.xzy,  k.xzz,
     k.yxx, k.yxy, k.yxz, 
    k.yyx, k.yyy, k.yyz,
    k.yzx, k.yzy, k.yzz,
    k.zxx, k.zxy, k.zxz, 
    k.zyx, k.zyy, k.zyz, 
    k.zzx, k.zzy, k.zzz
);


float gaussian( vec3 d, float s) { return exp(-( d.x*d.x + d.y*d.y + d.z*d.z ) / (2.0 * s*s)); }
float[27] generate_gaussian27_kernel(in float sigma)
{
    float sum = 0.0;
    float[27] gaussian_kernel;

    for (int i = 0; i < 27; i++)
    {
        gaussian_kernel[i] = gaussian(gaussian_k_offset[i], sigma);
        sum += gaussian_kernel[i];
    }

    // Normalize the kernel
    for (int i = 0; i < 27; i++) 
    {
        gaussian_kernel[i] /= sum;
    }

    return gaussian_kernel;
}

