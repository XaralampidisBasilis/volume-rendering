#ifndef UNIFORMS_RENDERING
#define UNIFORMS_RENDERING

struct Rendering 
{
    int   max_count;         
    int   max_cell_count;     
    int   max_block_count;   
};

uniform Rendering u_rendering;

#endif 