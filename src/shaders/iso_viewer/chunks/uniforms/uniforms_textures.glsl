#ifndef UNIFORMS_TEXTURES
#define UNIFORMS_TEXTURES

struct UniformsTextures 
{
    sampler3D interpolation_map;
    usampler3D occupancy_map;
    usampler3D distance_map;
};

uniform UniformsTextures u_textures;

#endif