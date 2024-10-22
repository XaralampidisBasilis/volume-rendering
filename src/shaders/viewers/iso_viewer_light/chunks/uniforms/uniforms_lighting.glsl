#ifndef UNIFORMS_LIGHTING
#define UNIFORMS_LIGHTING

// struct to hold lighting uniforms
struct uniforms_lighting 
{
    float power;
    vec3  color_a;
    vec3  color_d;
    vec3  color_s;
    vec3  offset_position;
    float has_attenuation;
};

uniform uniforms_lighting u_lighting;

#endif // UNIFORMS_LIGHTING
