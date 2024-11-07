#ifndef POSTERIZE
#define POSTERIZE

float posterize(in float grayscale, in float levels)
{
    // ensure levels is at least 2 to avoid division by zero
    levels = floor(max(levels, 2.0));

    // clamp value between 0.0 and 1.0
    grayscale = clamp(grayscale, 0.0, 1.0);

    // quantize the grayscale value
    float level = floor(grayscale * levels) / (levels - 1.0);

    return level;
}

// overload functions

vec3 posterize(vec3 color, float levels) {

    float grayscale = max(color.r, max(color.g, color.b));
    float level = posterize(grayscale, levels);
    float adjustment = level / grayscale;

    return color * adjustment;
}


#endif // POSTERIZE
