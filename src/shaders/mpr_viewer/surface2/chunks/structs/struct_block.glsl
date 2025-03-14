#ifndef STRUCT_BLOCK
#define STRUCT_BLOCK

struct Block 
{
    bool  intersected;
    bool  terminated;
    bool  occupied;
    int   cheby_distance;
    ivec3 coords;
    ivec3 coords_step;
    int   axis;
    ivec3 axes;
    ivec3 min_coords;
    ivec3 max_coords;
    vec3  min_position;
    vec3  max_position;
    float entry_distance;
    float exit_distance;
    float span_distance;
    vec3  entry_position;
    vec3  exit_position;
};

Block set_block()
{
    Block block;
    block.intersected    = false;
    block.terminated     = false;
    block.occupied       = false;
    block.cheby_distance = 1;
    block.coords         = ivec3(0);
    block.coords_step    = ivec3(0);
    block.axis           = 0;
    block.min_coords     = ivec3(0);
    block.max_coords     = ivec3(0);
    block.min_position   = vec3(0.0);
    block.max_position   = vec3(0.0);
    block.entry_distance = 0.0;
    block.exit_distance  = 0.0;
    block.span_distance  = 0.0;
    block.entry_position = vec3(0.0);
    block.exit_position  = vec3(0.0);
    return block;
}

#endif 
