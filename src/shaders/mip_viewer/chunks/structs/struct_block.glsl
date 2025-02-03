#ifndef STRUCT_BLOCK
#define STRUCT_BLOCK

// struct to hold the current occumap parameters
struct Block
{
    int   cheby_distance;
    bool  occupied;
    ivec3 coords;  
    ivec3 coords_step;
    ivec3 min_coords;
    ivec3 max_coords;
    vec3  min_position;
    vec3  max_position;
    float entry_distance;
    float exit_distance;
};

Block set_block()
{
    Block block;
    block.cheby_distance = 0;
    block.occupied       = false;
    block.coords         = ivec3(0);
    block.coords_step    = ivec3(0);
    block.min_coords     = ivec3(0);
    block.max_coords     = ivec3(0);
    block.min_position   = vec3(0.0);
    block.max_position   = vec3(0.0);
    block.entry_distance = 0.0;
    block.exit_distance  = 0.0;
    return block;
}

#endif // STRUCT_BLOCK