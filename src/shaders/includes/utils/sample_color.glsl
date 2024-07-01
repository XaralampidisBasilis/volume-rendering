#ifndef UTILS_SAMPLE_COLOR
#define UTILS_SAMPLE_COLOR

vec4 sample_color_2d(sampler2D colormap, in vec2 uv) 
{
    return texture(colormap, uv).rgba;
}

#endif // UTILS_SAMPLE_COLOR