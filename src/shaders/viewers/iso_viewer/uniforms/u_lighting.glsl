#ifndef LIGHTING_UNIFORMS
#define LIGHTING_UNIFORMS

// struct to hold lighting uniforms
struct lighting_uniforms 
{
    vec3 a_color;
    vec3 d_color;
    vec3 s_color;
    float ka;
    float kd;
    float ks;
    float shininess;
    float power;
    int model;
    bool attenuate;

};

uniform lighting_uniforms u_lighting;

#endif
