#ifndef UNIFORM_LIGHTING
#define UNIFORM_LIGHTING

// struct to hold lighting uniforms
struct Lighting 
{
    float power;
    vec3  color_a;
    vec3  color_d;
    vec3  color_s;
    vec3  offset_position;
    float has_attenuation;
};

#endif // UNIFORM_LIGHTING
