#ifndef SAMPLE_DISTANCE_ANISOTROPIC
#define SAMPLE_DISTANCE_ANISOTROPIC

// Samples the anisotropic distance texture at given coordinates and octant.
ivec3 sample_distance_anisotropic(in ivec3 block_coords, in int octant, out bool occupancy)
{        
    // Offset z to access the correct slab for the given octant.
    ivec3 slab_coords = block_coords;
    slab_coords.z += octant * u_volume.blocked_dimensions.z;

    // Fetch red channel from 3D texture
    uint texture_sample = texelFetch(u_textures.distance_map, slab_coords, 0).r;

    // Convert to integer distance
    int distance = int(texture_sample);

    // Determine occupancy based on distance == 0
    occupancy = (distance == 0);

    return ivec3(distance);
}

#endif
