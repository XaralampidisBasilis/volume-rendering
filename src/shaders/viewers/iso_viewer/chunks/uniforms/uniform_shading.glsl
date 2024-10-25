#ifndef UNIFORM_SHADING
#define UNIFORM_SHADING

// struct to hold shading uniforms
struct Shading
{
    float reflectance_a;
    float reflectance_d;
    float reflectance_s;
    float shininess;
    float shadow_threshold;
    float edge_threshold;
};

#endif // UNIFORM_SHADING
