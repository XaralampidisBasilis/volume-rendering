#ifndef COLORMAP_UNIFORMS
#define COLORMAP_UNIFORMS

// struct to hold colormap uniforms
struct colormap_uniforms 
{
    int name;
    float v;     
    vec2 u_range;
    vec2 u_lim;  

};

uniform colormap_uniforms u_colormap;

#endif
