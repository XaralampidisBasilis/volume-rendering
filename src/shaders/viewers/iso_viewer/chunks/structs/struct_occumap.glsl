#ifndef STRUCT_OCCUMAP
#define STRUCT_OCCUMAP

// struct to hold the current occumap parameters
struct Occumap
{
    int   lod;                   // level of detail for the current occupancy map
    float lod_scale;             // scale factor associated with the lod level
    ivec3 dimensions;            // dimensions of the current occupancy map in blocks
    vec3  inv_dimensions;        // inverse dimensions of the current occupancy map in blocks
    vec3  spacing;               // spacing between voxels in the occupancy map
    vec3  inv_spacing;           // inverse spacing between voxels in the occupancy map
    ivec3 start_coords;          // occupancy map offset inside occupamp atlas
    vec3  start_texture_coords;  // occupancy map offset inside occupamp atlas in normalized texture coords
    ivec3 block_dimensions;      // occupancy block dimensions in voxels
};

Occumap set_occumap()
{
    Occumap occumap;
    occumap.lod                  = 0;
    occumap.lod_scale            = 1.0;
    occumap.dimensions           = ivec3(0);
    occumap.inv_dimensions       = vec3(0.0);
    occumap.spacing              = vec3(0.0);
    occumap.inv_spacing          = vec3(0.0);
    occumap.start_coords         = ivec3(0);
    occumap.start_texture_coords = vec3(0.0);
    occumap.block_dimensions     = ivec3(0);
    return occumap;
}

#endif // STRUCT_OCCUMAP