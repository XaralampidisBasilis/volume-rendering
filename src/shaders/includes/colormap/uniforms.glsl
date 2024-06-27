#ifndef UNIFORMS_COLORMAP
#define UNIFORMS_COLORMAP

uniform sampler2D u_colormap_data;      // 2D texture containing the colormap data
uniform vec2 u_colormap_u_range;        // Range for the u-coordinate in the colormap texture
uniform vec2 u_colormap_u_lim;          // Limits to scale the input value 'u'
uniform float u_colormap_v;             // Fixed v-coordinate in the colormap texture that defines the colormap

#endif
