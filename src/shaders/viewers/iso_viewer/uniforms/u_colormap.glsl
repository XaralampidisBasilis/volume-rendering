#ifndef COLORMAP_UNIFORMS
#define COLORMAP_UNIFORMS

// struct to hold colormap uniforms
struct uniforms_colormap 
{
    int name;
    float v;     
    vec2 u_range;
    vec2 u_lim;  

};

uniform uniforms_colormap u_colormap;

#endif
