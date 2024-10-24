#ifndef PARAMETERS_BLOCK
#define PARAMETERS_BLOCK

// struct to hold gradient uniforms
struct parameters_block 
{
    bool occupied;
    int skips;
    int steps;
    int max_steps;
    float skipping;
    float spacing;
    float distance;
    ivec3 coords;
    vec3 texel;
    vec3 min_position;
    vec3 max_position;
};

void set(out parameters_block block)
{
    block.occupied     = false;
    block.skips        = 0;
    block.steps        = 0;
    block.max_steps    = 0;
    block.skipping     = 0.0;
    block.spacing      = 0.0;
    block.distance     = 0.0;
    block.coords       = ivec3(0);
    block.texel        = vec3(0.0);
    block.min_position = vec3(0.0);
    block.max_position = vec3(0.0);
}

#endif