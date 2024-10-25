#ifndef UNIFORM_VOLUME
#define UNIFORM_VOLUME

// struct to hold volume uniforms
struct Volume 
{
    vec3 dimensions;
    vec3 size;
    vec3 spacing;
    vec3 inv_dimensions;
    vec3 inv_size;
    vec3 inv_spacing;
};

#endif
