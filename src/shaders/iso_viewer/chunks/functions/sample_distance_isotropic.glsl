#ifndef SAMPLE_DISTANCE_ISOTROPIC
#define SAMPLE_DISTANCE_ISOTROPIC

// Samples the isotropic distance texture at given integer coordinates.
ivec3 sample_distance_isotropic(in ivec3 block_coords, out bool occupancy)
{
    // Fetch red channel value from the 3D texture
    uint texture_sample = texelFetch(u_textures.distance_map, block_coords, 0).r;

    // Convert to integer distance by flooring 
    int distance = int(texture_sample);

    // Determine if block is occupied 
    occupancy = (distance == 0);

    return ivec3(distance);
}

#endif