#ifndef SAMPLE_DISTANCE_EXTENDED
#define SAMPLE_DISTANCE_EXTENDED

#ifndef UNPACK_UINT_5551
#include "./unpack_uint_5551"
#endif

// Samples the extended distance texture at given coordinates and octant.
// Returns 3-component distance vector and sets occupancy flag.
ivec3 sample_distance_extended_anisotropic(in ivec3 block_coords, in int octant, out bool occupancy)
{
    // Offset z to access the correct slab for the given octant.
    ivec3 slab_coords = block_coords;
    slab_coords.z += octant * u_volume.blocked_dimensions.z;

    // Sample packed data from the 3D texture
    uint packed_sample = texelFetch(u_textures.distance_map, slab_coords, 0).r;

    // Unpack into 3 distances and 1 occupancy flag
    uvec4 unpacked_sample = unpack_uint_5551(packed_sample);

    // Get integer distances
    ivec3 distances = ivec3(unpacked_sample.rgb);

    // Get block occupancy
    occupancy = bool(unpacked_sample.a);

    return distances;
}

#endif
