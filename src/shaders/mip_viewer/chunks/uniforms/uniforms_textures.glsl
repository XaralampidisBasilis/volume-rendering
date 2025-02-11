#ifndef UNIFORMS_TEXTURES
#define UNIFORMS_TEXTURES

struct Textures 
{
    sampler3D intensity_map;
    sampler3D minima_distance_map;
    sampler3D maxima_distance_map;
    sampler2D color_maps;      
};

uniform Textures u_textures;

#endif