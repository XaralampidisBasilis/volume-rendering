#ifndef SAMPLER_UNIFORMS
#define SAMPLER_UNIFORMS
struct sampler_uniforms 
{
    sampler3D volume;
    sampler3D mask;
    sampler2D colormap;      
    sampler2D noise;
    sampler2D occupancy;
};

uniform sampler_uniforms u_sampler;


#endif