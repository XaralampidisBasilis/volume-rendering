#ifndef UTILS_SAMPLE_INTENSITY
#define UTILS_SAMPLE_INTENSITY

float sample_intensity(sampler3D intensity_data, vec3 uvw) 
{
    /* Sample float value from a 3D texture. Assumes intensity data. */
    return texture(intensity_data, uvw).r;
}

#endif