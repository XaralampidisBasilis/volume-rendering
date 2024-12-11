#ifndef UNIFORMS_TEXTURES
#define UNIFORMS_TEXTURES

struct Textures 
{
    sampler3D taylor_map;
    sampler3D distance_map;
    sampler2D color_maps;      
};

uniform Textures u_textures;

#endif