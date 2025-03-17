#ifndef STRUCT_VOXEL
#define STRUCT_VOXEL

struct Voxel 
{
    bool  intersected;
    bool  terminated;
    ivec3 coords;
    ivec3 coords_step;
    int   axis;
    vec3  min_position;
    vec3  max_position;
    float entry_distance;
    float exit_distance;
    vec3  entry_position;
    vec3  exit_position;
};

Voxel set_voxel()
{
    Voxel voxel;
    voxel.intersected    = false;
    voxel.terminated     = false;
    voxel.coords         = ivec3(0);
    voxel.coords_step    = ivec3(0);
    voxel.axis           = 0;
    voxel.min_position   = vec3(0.0);
    voxel.max_position   = vec3(0.0);
    voxel.entry_distance = 0.0;
    voxel.exit_distance  = 0.0;
    voxel.entry_position = vec3(0.0);
    voxel.exit_position  = vec3(0.0);
    return voxel;
}

#endif 
