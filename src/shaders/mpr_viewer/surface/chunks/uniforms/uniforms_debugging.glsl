#ifndef UNIFORMS_DEBUGGING
#define UNIFORMS_DEBUGGING

struct Debugging
{
    int option;    
    int trace_count;
    int cell_count;
    int block_count;
    float variable1; 
    float variable2; 
    float variable3; 
};

uniform Debugging u_debugging;

#endif 