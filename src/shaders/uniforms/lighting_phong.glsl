#ifndef UNIFORMS_LIGHTING_PHONG
#define UNIFORMS_LIGHTING_PHONG

uniform vec3 u_lighting_a_color;
uniform vec3 u_lighting_d_color;
uniform vec3 u_lighting_s_color;

uniform float u_lighting_ka; 
uniform float u_lighting_kd; 
uniform float u_lighting_ks; 

uniform bool u_lighting_attenuate;
uniform float u_lighting_shininess;
uniform float u_lighting_power;
uniform int u_lighting_mode;

#endif
