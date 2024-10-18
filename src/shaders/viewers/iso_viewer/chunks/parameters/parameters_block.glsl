#ifndef PARAMETERS_BLOCK
#define PARAMETERS_BLOCK

// struct to hold gradient uniforms
struct parameters_block 
{
    int lod;
    float occupancy;
    bool occupied;
    float skip_depth;
    ivec3 coords;
    vec3 texel;
    vec3 size;
    vec3 min_position;
    vec3 max_position;
};

void set_block(out parameters_block block)
{
    block.lod          = 0;
    block.occupancy    = 0.0;
    block.occupied     = false;
    block.skip_depth   = 0.0;
    block.coords       = ivec3(0);
    block.texel        = vec3(0);
    block.size         = vec3(0.0);
    block.min_position = vec3(0.0);
    block.max_position = vec3(0.0);
}

#endif