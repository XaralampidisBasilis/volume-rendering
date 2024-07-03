#ifndef COLORMAP_UNIFORMS
#define COLORMAP_UNIFORMS

uniform vec2 u_colormap_u_range;       // Range for the u-coordinate in the colormap texture
uniform vec2 u_colormap_u_lim;         // Limits to scale the input value 'u'
uniform float u_colormap_v;            // Fixed v-coordinate in the colormap texture that defines the colormap

// struct to hold colormap uniforms
struct colormap_uniforms 
{
    vec2 u_range;
    vec2 u_lim;  
    float v;     

};

#endif
