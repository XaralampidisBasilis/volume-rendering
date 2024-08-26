#ifndef SAMPLER_UNIFORMS
#define SAMPLER_UNIFORMS
struct uniforms_sampler 
{
    sampler3D volume;
    sampler3D gradients;
    sampler3D mask;
    sampler2D colormap;      
    sampler2D noisemap;
    sampler3D occumaps[3];
};

uniform uniforms_sampler u_sampler;


#endif