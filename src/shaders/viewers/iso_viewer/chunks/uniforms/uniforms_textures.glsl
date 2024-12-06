#ifndef UNIFORMS_TEXTURES
#define UNIFORMS_TEXTURES

struct Textures 
{
    sampler3D taylormap;
    sampler3D distmap;
    sampler2D colormaps;      
};

uniform Textures u_textures;

#endif