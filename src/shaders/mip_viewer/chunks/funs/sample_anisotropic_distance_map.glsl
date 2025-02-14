int sample_anisotropic_distance_map(ivec3 coords, int index)
{
    // Sample the 3D texture (returns vec4 in [0,1] range)
    vec4 tex_sample = texelFetch(u_textures.anisotropic_distance_map, coords, 0);
    
    // Convert to unsigned integer format (0-255)
    uvec4 tex_data = uvec4(round(tex_sample * 255.0));

    // Each channel contains two 4-bit values
    // Determine the source channel (0: R, 1: G, 2: B, 3: A)
    int channel = index / 2;
    
    // Determine bit position (0: lower 4 bits, 1: upper 4 bits)
    int bit_position = (index % 2) * 4;

    // Extract 4-bit integer value
    return int((tex_data[channel] >> bit_position) & uint(0xF));
}