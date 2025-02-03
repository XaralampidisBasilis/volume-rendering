#ifndef STRUCT_FRAG
#define STRUCT_FRAG

struct Frag 
{
    float depth;             // depth traveled from camera in NDC space
    vec3  position;          // position in NDC space
    float mapped_intensity;  // sampled value at the current position
    vec4  mapped_color;      // color mapped from the voxel value
    float camera_angle;
};

Frag set_frag()
{
    Frag frag;
    frag.depth            = 0.0;
    frag.position         = vec3(0.0);
    frag.mapped_intensity = 0.0;
    frag.mapped_color     = vec4(vec3(0.0), 1.0);
    frag.camera_angle     = 0.0;
    return frag;
}

void discard_frag(inout Frag frag)
{
    frag.depth            = 0.0;
    frag.position         = vec3(0.0);
    frag.mapped_intensity = 0.0;
    frag.mapped_color     = vec4(vec3(0.0), 1.0);
    frag.camera_angle     = 0.0;
}

#endif // STRUCT_FRAG
