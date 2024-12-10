#ifndef STRUCT_DOXEL
#define STRUCT_DOXEL

struct Doxel 
{
    ivec3  coords;
    vec3  min_position;
    vec3  max_position;
};

Doxel set_doxel()
{
    Doxel doxel;
    doxel.coords       = ivec3(0);
    doxel.min_position = vec3(0.0);
    doxel.max_position = vec3(0.0);
    return doxel;
}

void discard_doxel(inout Doxel doxel)
{
}

#endif // STRUCT_DOXEL
