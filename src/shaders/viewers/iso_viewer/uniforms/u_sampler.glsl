#ifndef SAMPLER_UNIFORMS
#define SAMPLER_UNIFORMS
struct uniforms_sampler 
{
    sampler3D volume;
    sampler3D mask;
    sampler2D colormap;      
    sampler2D noise;
    sampler2D occupancy;
};

uniform uniforms_sampler u_sampler;


#endif