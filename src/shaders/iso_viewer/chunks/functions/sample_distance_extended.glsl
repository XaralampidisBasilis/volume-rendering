#ifndef SAMPLE_DISTANCE_EXTENDED
#define SAMPLE_DISTANCE_EXTENDED

// Unpacks a 16-bit 5551-encoded extended distance sample into 3 distances and 1 occupancy bit.
uvec4 unpack_sample(in uint packed_sample)
{
    return uvec4(
        (packed_sample >> 11u) & 0x1Fu, // Extract bits 15–11: X distance
        (packed_sample >>  6u) & 0x1Fu, // Extract bits 10–6:  Y distance
        (packed_sample >>  1u) & 0x1Fu, // Extract bits 5–1:   Z distance
        (packed_sample >>  0u) & 0x01u  // Extract bit 0:      Occupancy
    );
}

// Samples the extended distance texture at given coordinates and octant.
// Returns 3-component distance vector and sets occupancy flag.
ivec3 sample_distance_extended(in ivec3 block_coords, in int octant, out bool occupancy)
{
    ivec3 dimensions = textureSize(u_textures.distance_map, 0);

    // Offset z to access the correct slab for the given octant.
    ivec3 slab_coords = block_coords;
    slab_coords.z += octant * dimensions.z;

    // Sample packed data from the 3D texture
    uint packed_sample = texelFetch(u_textures.distance_map, slab_coords, 0).r;

    // Unpack into 3 distances and 1 occupancy flag
    uvec4 unpacked_sample = unpack_sample(packed_sample);

    // Get integer distances
    ivec3 distances = ivec3(unpacked_sample.rgb);

    // Get block occupancy
    occupancy = bool(unpacked_sample.a);

    return distances;
}

#endif
