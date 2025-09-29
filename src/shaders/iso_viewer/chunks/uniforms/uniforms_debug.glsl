#ifndef UNIFORMS_DEBUG
#define UNIFORMS_DEBUG

struct UniformsDebug
{
    int option;    
    int   max_groups;         
    int   max_cells;     
    int   max_blocks;   
    float variable1; 
    float variable2; 
    float variable3; 
    float variable4; 
    float variable5; 
};

uniform UniformsDebug u_debug;

#endif 