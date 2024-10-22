#ifndef UNIFORMS_SHADING
#define UNIFORMS_SHADING

// struct to hold shading uniforms
struct uniforms_shading 
{
    float reflectance_a;
    float reflectance_d;
    float reflectance_s;
    float shininess;
    float shadow_threshold;
    float edge_threshold;
    int model;
    bool attenuation;
};

uniform uniforms_shading u_shading;

#endif
