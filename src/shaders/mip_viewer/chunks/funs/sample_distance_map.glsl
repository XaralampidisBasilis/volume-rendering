int sample_distance_map(ivec3 coords)
{
    // Sample the 3D texture (returns float in [0,1] range)
    float tex_sample = texelFetch(u_textures.distance_map, coords, 0).r;
    
    // Convert to integer format (0-255)
    int tex_data =int(round(tex_sample));

    // Extract 4-bit integer value
    return tex_data;
}