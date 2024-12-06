#ifndef STRUCT_FRAG
#define STRUCT_FRAG

struct Frag 
{
    float depth;         // fragment depth traveled from camera
    float value;         // sampled value at the current position
    vec3  normal;        // normal vector derived from voxel gradient
    vec4  mapped_color;  // color mapped from the voxel value
    vec4  shaded_color;  // color after shading has been applied
};

Frag set_frag()
{
    Frag frag;
    frag.depth        = 0.0;
    frag.value        = 0.0;
    frag.normal       = vec3(0.0);
    frag.mapped_color = vec4(vec3(0.0), 1.0);
    frag.shaded_color = vec4(vec3(0.0), 1.0);
    return frag;
}

void discard_frag(inout Frag frag)
{
}

#endif STRUCT_FRAG
