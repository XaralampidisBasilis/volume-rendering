#ifndef LIGHTING_UNIFORMS
#define LIGHTING_UNIFORMS

// struct to hold lighting uniforms
struct uniforms_lighting 
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

uniform uniforms_lighting u_lighting;

#endif
