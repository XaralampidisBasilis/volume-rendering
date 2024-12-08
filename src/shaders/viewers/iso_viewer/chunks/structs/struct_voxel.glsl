#ifndef STRUCT_VOXEL
#define STRUCT_VOXEL

struct Voxel 
{
    ivec3 coords;
    vec3  texture_coords;  // normalized texture coordinates
    vec3  gradient;        // gradient vector
    float value;           // sampled value at the current position
};

Voxel set_voxel()
{
    Voxel voxel;
    voxel.coords         = ivec3(0);
    voxel.texture_coords = vec3(0.0);
    voxel.gradient       = vec3(0.0);
    voxel.value          = 0.0;
    return voxel;
}
void discard_voxel(inout Voxel voxel)
{
    voxel.texture_coords = voxel.texture_coords;
    voxel.gradient       = voxel.gradient;
    voxel.value          = voxel.value;
}

#endif // STRUCT_VOXEL
