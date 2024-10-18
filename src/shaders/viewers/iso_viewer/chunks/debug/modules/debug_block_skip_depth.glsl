
float block_skip_depth = block.skip_depth / ray.global_max_depth;

debug.block_skip_depth = vec4(vec3(block_skip_depth), 1.0);