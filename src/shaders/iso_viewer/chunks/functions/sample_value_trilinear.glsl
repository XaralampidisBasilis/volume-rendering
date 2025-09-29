// Samples the base volume using standard trilinear interpolation.
// Assumes texture uses linear filtering and normalized coordinates.
#ifndef SAMPLE_VALUE_TRILINEAR
#define SAMPLE_VALUE_TRILINEAR

float sample_value_trilinear(in vec3 coords)
{
    // Normalize coordinates to texture space [0,1]
    coords *= u_volume.inv_dimensions;

    float value = texture(u_textures.interpolation_map, coords).a;

    return value;
}

#endif