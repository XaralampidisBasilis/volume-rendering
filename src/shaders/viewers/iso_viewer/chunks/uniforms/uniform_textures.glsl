#ifndef UNIFORM_TEXTURES
#define UNIFORM_TEXTURES

struct Textures 
{
    sampler3D volume;
    sampler3D mask;
    sampler3D occumaps;
    sampler2D colormaps;      
    sampler2D noisemap;
};

uniform Textures u_textures;

#endif