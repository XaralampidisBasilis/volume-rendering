#ifndef UTILS_SAMPLE_COLOR
#define UTILS_SAMPLE_COLOR

vec3 sample_color_2d(sampler2D colormap, in vec2 uv) 
{
    return texture(colormap, uv).rgb;
}

#endif // UTILS_SAMPLE_COLOR