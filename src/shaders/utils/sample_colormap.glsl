#ifndef UTILS_SAMPLE_COLORMAP
#define UTILS_SAMPLE_COLORMAP

float sample_colormap(in sampler3D colormap, in vec2 uv) 
{
    /* Sample float value from a 3D texture. Assumes intensity data. */
    return texture(colormap, uv).rgb;
}

#endif