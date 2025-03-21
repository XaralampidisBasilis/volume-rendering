#ifndef UNIFORMS_SLICE
#define UNIFORMS_SLICE

struct Slice 
{
    mat4 matrix; 
    vec4 hessian;
    bool visible;  
};

uniform Slice slice;

#endif 