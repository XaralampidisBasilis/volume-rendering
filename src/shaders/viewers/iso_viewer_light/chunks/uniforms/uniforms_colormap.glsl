#ifndef COLORMAP_UNIFORMS
#define COLORMAP_UNIFORMS

// struct to hold colormap uniforms
struct uniforms_colormap 
{
    int name;
    float texture_row;     
    vec2 texture_columns;
    float low;  
    float high;  
    float levels;
};

uniform uniforms_colormap u_colormap;

#endif
