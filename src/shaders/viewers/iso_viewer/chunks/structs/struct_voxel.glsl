#ifndef STRUCT_VOXEL
#define STRUCT_VOXEL

struct Voxel 
{
    vec3  texture_coords;  // normalized texture coordinates
    float value;           // sampled value at the current position
    vec3  gradient;        // gradient vector
    vec4  mapped_value;    // color mapped from the sample value
};

Voxel set_voxel()
{
    Voxel voxel;
    voxel.value          = 0.0;
    voxel.texture_coords = vec3(0.0);
    voxel.gradient       = vec3(0.0);
    voxel.mapped_value   = 0.0;
    return voxel;
}
void discard_voxel(inout Voxel voxel)
{
    voxel.value          = voxel.value;
    voxel.texture_coords = voxel.texture_coords;
    voxel.gradient       = voxel.gradient;
    voxel.mapped_value   = voxel.mapped_value;
}


#endif // STRUCT_VOXEL
