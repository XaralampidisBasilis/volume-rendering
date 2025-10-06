#ifndef UNIFORMS_BBOX
#define UNIFORMS_BBOX

struct UniformsBbox 
{
    vec3 min_position;
    vec3 max_position;
};

uniform UniformsBbox u_bbox;

#endif
