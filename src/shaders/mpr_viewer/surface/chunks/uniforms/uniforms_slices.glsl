#ifndef UNIFORMS_SLICES
#define UNIFORMS_SLICES

struct Slices 
{
    vec4  hessian[3];
    float visible[3];
};

uniform Slices u_slices;

#endif
