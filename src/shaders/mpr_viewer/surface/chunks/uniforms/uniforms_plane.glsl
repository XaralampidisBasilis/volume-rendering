#ifndef UNIFORMS_PLANE
#define UNIFORMS_PLANE

struct Plane 
{
    mat4 transform; 
    vec4 hessian;  
};

uniform Plane u_plane;

#endif 