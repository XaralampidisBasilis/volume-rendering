#ifndef PARAMETERS_BLOCK
#define PARAMETERS_BLOCK

// struct to hold gradient uniforms
struct parameters_block 
{
    bool occupied;
    float skipping;
    ivec3 coords;
    vec3 min_position;
    vec3 max_position;
};

void set(out parameters_block block)
{
    block.occupied     = false;
    block.skipping     = 0.0;
    block.coords       = ivec3(0);
    block.min_position = vec3(0.0);
    block.max_position = vec3(0.0);
}

#endif