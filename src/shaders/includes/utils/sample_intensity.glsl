#ifndef UTILS_SAMPLE_INTENSITY
#define UTILS_SAMPLE_INTENSITY

float sample_intensity_2d(sampler2D intensity_data, in vec2 uv) 
{
    /* Sample float value from a 2D texture. Assumes intensity data. */
    return texture(intensity_data, uv).r;
}

float sample_intensity_3d(sampler3D intensity_data, in vec3 uvw) 
{
    /* Sample float value from a 3D texture. Assumes intensity data. */
    return texture(intensity_data, uvw).r;
}

#endif // UTILS_SAMPLE_INTENSITY