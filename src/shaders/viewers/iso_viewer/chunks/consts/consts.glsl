

const ivec2 base_offset = ivec2(0, 1);
const ivec3 base_offsets[8] = ivec3[8]
(
    base_offset.xxx, base_offset.xxy, 
    base_offset.xyx, base_offset.xyy, 
    base_offset.yxx, base_offset.yxy,
    base_offset.yyx, base_offset.yyy 
);

const vec2 centered_offset = vec2(-0.5, 0.5);
const vec3 centered_offsets[8] = vec3[8]
(
    centered_offset.xxx, centered_offset.xxy, 
    centered_offset.xyx, centered_offset.xyy, 
    centered_offset.yxx, centered_offset.yxy,
    centered_offset.yyx, centered_offset.yyy 
);


const int MAX_TRACE_STEP_COUNT = 1000;
const int MAX_BLOCK_SKIP_COUNT = 500;

const float MIN_TRACE_STEP_SCALING = 0.01;
const float MAX_TRACE_STEP_SCALING = 5.00;