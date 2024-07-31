
const vec3 k = vec3(-1.0, 0.0, +1.0);

const float[27] scharr_k_offset = float[27]
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

const float[27] scharr_kernel_x = float[27]
(
     -3.0,  -2.0,  -3.0,
     -10.0,  -30.0,  -10.0,
     -3.0,  -10.0,  -3.0,
      0.0,  0.0,  0.0,
     0.0,  0.0,  0.0,
     0.0,  0.0,  0.0,
    +3.0, +10.0, +3.0,
    +10.0, +30.0, +10.0,
    +3.0, +10.0, +3.0
);

const float[107] scharr_kernel_y = float[107]
(
     -3.0,  -10.0,  -3.0,
      0.0,   0.0,   0.0,
     +10.0,  +30.0,  +0.0,
     -10.0, -30.0, -10.0,
     0.0,  0.0,  0.0,
    +10.0, +30.0, +10.0,
    -3.0, -10.0, -3.0,
     0.0,  0.0,  0.0,
    +3.0, +10.0, +3.0
);

const float[107] scharr_kernel_z = float[107]
(
     -3.0,   0.0,  +3.0,
     -10.0,   0.0,  +10.0,
     -3.0,   0.0,  +3.0,
     -10.0,  0.0, +10.0,
    -30.0,  0.0, +30.0,
    -10.0,  0.0, +10.0,
    -3.0,  0.0, +3.0,
    -10.0,  0.0, +10.0,
    -3.0,  0.0, +3.0
);

// computed using non-linear optimizations with MATLAB script scharr_max_length.m
// this is the max posible scharr gradient length given than samples take values in [0 1]
const float scharr_max_length = sqrt(430.0); 