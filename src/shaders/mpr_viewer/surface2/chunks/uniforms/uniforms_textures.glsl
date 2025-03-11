#ifndef UNIFORMS_TEXTURES
#define UNIFORMS_TEXTURES

struct Textures 
{
    sampler3D intensity_map;
    sampler3D binary_map;
    sampler3D distance_map;
};

uniform Textures u_textures;

#endif