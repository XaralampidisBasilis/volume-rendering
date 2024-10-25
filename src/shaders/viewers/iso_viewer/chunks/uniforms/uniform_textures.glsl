#ifndef UNIFORM_TEXTURES
#define UNIFORM_TEXTURES

struct Textures 
{
    sampler3D volume;
    sampler3D mask;
    sampler2D colormap;      
    sampler2D noisemap;
    sampler3D occumaps;
};

#endif