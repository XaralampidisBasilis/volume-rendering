#ifndef COLORMAP_UNIFORMS
#define COLORMAP_UNIFORMS

// struct to hold colormap uniforms
struct uniforms_colormap 
{
    int name;
    float texture_id;     
    vec2 texture_range;
    float low;  
    float high;  
    float levels;
};

uniform uniforms_colormap u_colormap;

#endif
