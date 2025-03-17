#ifndef UNIFORMS_BBOX
#define UNIFORMS_BBOX

struct Bbox 
{
    ivec3 dimensions;
    ivec3 min_coords;
    ivec3 max_coords;
    vec3  min_position;
    vec3  max_position;
};

uniform Bbox u_bbox;

#endif
