#ifndef PARAMETERS_BLOCK
#define PARAMETERS_BLOCK

// struct to hold gradient uniforms
struct parameters_block 
{
    ivec3 coords;
    vec3 min_position;
    vec3 max_position;
    vec3 size;
    float resolutuon;
    float max_depth;
    int max_steps;
    bool occupied; 
};

void set_block(inout parameters_block block)
{
    block.coords       = ivec3(0);
    block.min_position = vec3(0.0);
    block.max_position = vec3(0.0);
    block.size         = vec3(0.0);
    block.resolutuon   = 0.0;
    block.max_depth    = 0.0;
    block.max_steps    = 0;
    block.occupied     = false;
}

#endif