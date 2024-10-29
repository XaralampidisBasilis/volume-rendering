#ifndef STRUCT_OCCUMAP
#define STRUCT_OCCUMAP

// struct to hold the current occumap parameters
struct Occumap
{
    int   lod;           // level of detail for the current occupancy map
    float lod_scale;     // scale factor associated with the lod level
    ivec3 dimensions;    // dimensions of the current occupancy map in blocks
    ivec3 start_coords;  // occupancy map offset inside occupamp atlas
    vec3  spacing;       // spacing between voxels in the occupancy map
};

Occumap set_occumap()
{
    Occumap occumap;
    occumap.lod          = 0;
    occumap.lod_scale    = 1.0;
    occumap.dimensions   = ivec3(0);
    occumap.start_coords = ivec3(0);
    occumap.spacing      = vec3(0.0);
    return occumap;
}

#endif // STRUCT_OCCUMAP