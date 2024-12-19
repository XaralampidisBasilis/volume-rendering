#ifndef STRUCT_VOXEL
#define STRUCT_VOXEL

struct Voxel 
{
    bool  saturated;
    ivec3 coords;
    vec3  position;
    vec3  min_position;
    vec3  max_position;
    vec3  texture_coords;  // normalized texture coordinates
    vec3  gradient;        // gradient vector
    float value;           // sampled value at the current position
};

Voxel set_voxel()
{
    Voxel voxel;
    voxel.saturated      = false;
    voxel.coords         = ivec3(0);
    voxel.position       = vec3(0.0);
    voxel.min_position   = vec3(0.0);
    voxel.max_position   = vec3(0.0);
    voxel.texture_coords = vec3(0.0);
    voxel.gradient       = vec3(0.0);
    voxel.value          = 0.0;
    return voxel;
}

#endif // STRUCT_VOXEL
