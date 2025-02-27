#ifndef UNIFORMS_BOUNDING_BOX
#define UNIFORMS_BOUNDING_BOX

struct BoundingBox 
{
    vec3 dimensions;
    vec3 min_coords;
    vec3 max_coords;
    vec3 min_position;
    vec3 max_position;
};

uniform BoundingBox u_bounding_box;

#endif
