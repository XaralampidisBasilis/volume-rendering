#ifndef LIGHTING_UNIFORMS
#define LIGHTING_UNIFORMS

// uniforms for ambient, diffuse, and specular lighting colors
uniform mediump vec3 u_lighting_a_color;
uniform mediump vec3 u_lighting_d_color;
uniform mediump vec3 u_lighting_s_color;

// uniforms for ambient, diffuse, and specular coefficients
uniform mediump float u_lighting_ka; 
uniform mediump float u_lighting_kd; 
uniform mediump float u_lighting_ks; 

// uniforms for other lighting parameters
uniform lowp bool u_lighting_attenuate;
uniform mediump float u_lighting_shininess;
uniform mediump float u_lighting_power;
uniform lowp int u_lighting_mode;

// struct to hold lighting uniforms
struct lighting_uniforms 
{
    lowp bool attenuate;
    mediump float shininess;
    mediump float power;
    lowp int mode;
    mediump vec3 a_color;
    mediump vec3 d_color;
    mediump vec3 s_color;
    mediump float ka;
    mediump float kd;
    mediump float ks;   
};

// function to set light uniforms struct
lighting_uniforms set_lighting_uniforms() 
{
    lighting_uniforms u_lighting;

    u_lighting.attenuate = u_lighting_attenuate;
    u_lighting.shininess = u_lighting_shininess;
    u_lighting.power     = u_lighting_power;
    u_lighting.mode      = u_lighting_mode;
    u_lighting.a_color   = u_lighting_a_color;
    u_lighting.d_color   = u_lighting_d_color;
    u_lighting.s_color   = u_lighting_s_color;
    u_lighting.ka        = u_lighting_ka;
    u_lighting.kd        = u_lighting_kd;
    u_lighting.ks        = u_lighting_ks;

    return u_lighting;
}

#endif
