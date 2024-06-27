#ifndef COLORMAP_UNIFORMS
#define COLORMAP_UNIFORMS

uniform highp sampler2D u_colormap_data;       // 2D texture containing the colormap data
uniform mediump vec2 u_colormap_u_range;       // Range for the u-coordinate in the colormap texture
uniform mediump vec2 u_colormap_u_lim;         // Limits to scale the input value 'u'
uniform mediump float u_colormap_v;            // Fixed v-coordinate in the colormap texture that defines the colormap

// struct to hold colormap uniforms
struct colormap_uniforms 
{
    highp sampler2D data;
    mediump vec2 u_range;
    mediump vec2 u_lim;  
    mediump float v;     

};

// function to set light uniforms struct
colormap_uniforms set_colormap_uniforms() 
{
    colormap_uniforms u_colormap;

    u_colormap.data = u_colormap_data;
    u_colormap.u_range = u_colormap_u_range;
    u_colormap.u_lim = u_colormap_u_lim;
    u_colormap.v = u_colormap_v;

    return u_colormap;
}

#endif
