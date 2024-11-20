#ifndef UNIFORM_TEXTURES
#define UNIFORM_TEXTURES

struct Textures 
{
    sampler3D volume;
    sampler3D mask;
    sampler3D extremap;
    sampler2D colormaps;      
    sampler2D noisemap;
};

#endif