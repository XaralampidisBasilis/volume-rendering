#ifndef UNIFORMS_SLICE
#define UNIFORMS_SLICE

struct Slice 
{
    mat4 transform; 
    vec4 hessian;  
};

uniform Slice u_slice;

#endif 