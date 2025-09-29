#ifndef SAMPLE_OCCUPANCY
#define SAMPLE_OCCUPANCY

// Samples the occupancy texture at the given integer coordinates.
bool sample_occupancy(in ivec3 block_coords)
{
    // Fetch red channel value from occupancy texture
    uint texture_sample = texelFetch(u_textures.occupancy_map, block_coords, 0).r;

    // Convert non-zero texel to occupancy flag
    bool occupancy = (texture_sample > 0u);
    
    return occupancy;
}

#endif