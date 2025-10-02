#ifndef UNIFORMS_DEBUG
#define UNIFORMS_DEBUG

struct UniformsDebug
{
    int option;
    int max_groups;         
    int max_blocks;         
    int max_cells;             
    float variable1; 
    float variable2; 
    float variable3; 
    float variable4; 
    float variable5; 
};

uniform UniformsDebug u_debug;

#endif 