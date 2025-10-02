#ifndef SAMPLE_DISTANCE_EXTENDED_ISOTROPIC
#define SAMPLE_DISTANCE_EXTENDED_ISOTROPIC

#ifndef UNPACK_UINT_5551
#include "./unpack_uint_5551"
#endif

// Samples the isotropic distance texture at given integer coordinates.
void sample_distance_extended_isotropic(in ivec3 block_coords, out ivec3 min_distances, out ivec3 max_distances, out bool occupancy)
{
    // Fetch red channel value from the 3D texture
    uvec2 packed_samples = texelFetch(u_textures.distance_map, block_coords, 0).rg;

    // Unpack into 3 distances and 1 occupancy flag
    uvec4 min_unpacked_samples = unpack_uint_5551(packed_samples.r);
    uvec4 max_unpacked_samples = unpack_uint_5551(packed_samples.g);

    // Get integer distances
    min_distances = ivec3(min_unpacked_samples.rgb);
    max_distances = ivec3(max_unpacked_samples.rgb);

    // Get block occupancy
    occupancy = bool(min_unpacked_samples.a);
}

#endif
