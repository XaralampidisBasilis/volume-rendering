#ifndef LIGHTING_UNIFORMS
#define LIGHTING_UNIFORMS

// uniforms for ambient, diffuse, and specular lighting colors
uniform vec3 u_lighting_a_color;
uniform vec3 u_lighting_d_color;
uniform vec3 u_lighting_s_color;

// uniforms for ambient, diffuse, and specular coefficients
uniform float u_lighting_ka; 
uniform float u_lighting_kd; 
uniform float u_lighting_ks; 

// uniforms for other lighting parameters
uniform bool u_lighting_attenuate;
uniform float u_lighting_shininess;
uniform float u_lighting_power;
uniform int u_lighting_model;

// struct to hold lighting uniforms
struct lighting_uniforms 
{
    bool attenuate;
    float shininess;
    float power;
    int model;
    vec3 a_color;
    vec3 d_color;
    vec3 s_color;
    float ka;
    float kd;
    float ks;   
};

#endif
