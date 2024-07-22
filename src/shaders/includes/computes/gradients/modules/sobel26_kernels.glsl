
const vec3 k = vec3(1.0, 0.0, -1.0);

const vec3[27] sobel_k_offset = vec3[27]
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

const float[27] sobel_kernel_x = float[27]
(
     +1.0,  +2.0,  +1.0,
     +2.0,  +4.0,  +2.0,
     +1.0,  +2.0,  +1.0,
      0.0,  0.0,  0.0,
     0.0,  0.0,  0.0,
     0.0,  0.0,  0.0,
    -1.0, -2.0, -1.0,
    -2.0, -4.0, -2.0,
    -1.0, -2.0, -1.0
);

const float[27] sobel_kernel_y = float[27]
(
     +1.0,  +2.0,  +1.0,
      0.0,   0.0,   0.0,
     -2.0,  -4.0,  -0.0,
     +2.0, +4.0, +2.0,
     0.0,  0.0,  0.0,
    -2.0, -4.0, -2.0,
    +1.0, +2.0, +1.0,
     0.0,  0.0,  0.0,
    -1.0, -2.0, -1.0
);

const float[27] sobel_kernel_z = float[27]
(
     +1.0,   0.0,  -1.0,
     +2.0,   0.0,  -2.0,
     +1.0,   0.0,  -1.0,
     +2.0,  0.0, -2.0,
    +4.0,  0.0, -4.0,
    +2.0,  0.0, -2.0,
    +1.0,  0.0, -1.0,
    +2.0,  0.0, -2.0,
    +1.0,  0.0, -1.0
);

// computed using non-linear optimizations with MATLAB script sobel_max_length.m
// this is the max posible sobel gradient length given than samples take values in [0 1]
const float sobel_max_length = sqrt(430.0); 