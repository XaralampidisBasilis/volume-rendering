#ifndef UTILS_SAMPLE_TEXTURE_3D
#define UTILS_SAMPLE_TEXTURE_3D

float sample_texture_3d(sampler3D data, vec3 position) 
{
    /* Sample float value from a 3D texture. Assumes intensity data. */
    return texture(data, position).r;
}

#endif