#ifndef STRUCT_BLOCK
#define STRUCT_BLOCK

// struct to hold the current occumap parameters
struct Block
{
    float max_intensity;
    bool  occupied;
    ivec3 coords;  
    ivec3 coords_step;
    vec3  min_position;
    vec3  max_position;
    float entry_distance;
    float exit_distance;
};

Block set_block()
{
    Block block;
    block.max_intensity  = 0;
    block.occupied       = false;
    block.coords         = ivec3(0);
    block.coords_step    = ivec3(0);
    block.min_position   = vec3(0.0);
    block.max_position   = vec3(0.0);
    block.entry_distance = 0.0;
    block.exit_distance  = 0.0;
    return block;
}

#endif // STRUCT_BLOCK