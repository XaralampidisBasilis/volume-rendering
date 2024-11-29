#ifndef STRUCT_BLOCK
#define STRUCT_BLOCK

// struct to hold the current occumap parameters
struct Block
{
    int   chebyshev_distance;
    bool  occupied;
    ivec3 coords;
    ivec3 dimensions; 
    vec3  size;     
    vec3  min_position;
    vec3  max_position;
};

Block set_block()
{
    Block block;
    block.chebyshev_distance = 0;
    block.occupied = false;
    block.coords = ivec3(0);
    block.dimensions = ivec3(0);   
    block.size = vec3(0.0);   
    block.min_position = vec3(0.0);
    block.max_position = vec3(0.0);
    return block;
}

#endif // STRUCT_BLOCK