
// For kernel convolution
const ivec2 binary_offset = ivec2(0, 1);
const vec2 center_offset = vec2(-0.5, 0.5);
const ivec3 binary_offsets[8] = ivec3[8]
(
    binary_offset.xxx, binary_offset.yxx, 
    binary_offset.xyx, binary_offset.xxy, 
    binary_offset.xyy, binary_offset.yxy,
    binary_offset.yyx, binary_offset.yyy 
);
const vec3 center_offsets[8] = vec3[8]
(
    center_offset.xxx, center_offset.yxx, 
    center_offset.xyx, center_offset.xxy, 
    center_offset.xyy, center_offset.yxy,
    center_offset.yyx, center_offset.yyy 
);

// For polynomial interpolation
const vec2 weights_vec2 = vec2(0.0, 1.0);
const vec3 weights_vec3 = vec3(0.0, 0.5, 1.0);
const vec4 weights_vec4 = vec4(0.0, 1.0/3.0, 2.0/3.0, 1.0);
const mat2 inv_vander_mat2 = mat2
(
    1.0, -1.0,   
    0.0,  1.0   
);
const mat3 inv_vander_mat3 = mat3
(
    1.0, -3.0,  2.0,  
    0.0,  4.0, -4.5,  
    0.0, -1.0,  2.0
);
const mat4 inv_vander_mat4 = mat4
(
     1.0, -5.5,   9.0,   -4.5,
     0.0,  9.0, -22.5,   13.5,
     0.0, -4.5, 18.0, -13.5,
    0.0, 1.0, -4.5,   4.5 
);

// For stats upper limits
const int MAX_NUM_FETCHES = MAX_BATCH_COUNT * (MAX_BLOCK_SUB_COUNT + MAX_CELL_SUB_COUNT * 3 + 1) + 12;
const int MAX_NUM_STEPS = MAX_BATCH_COUNT * (MAX_BLOCK_SUB_COUNT);
const int MAX_NUM_SKIPS = MAX_BATCH_COUNT * (MAX_BLOCK_SUB_COUNT + MAX_CELL_SUB_COUNT);