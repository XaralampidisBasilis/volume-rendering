#ifndef UNIFORMS_SHADING
#define UNIFORMS_SHADING

struct UniformsShading
{
    int   colormap;
    float shininess;           
    float reflect_ambient; 
    float reflect_diffuse; 
    float reflect_specular;
    float modulate_edges;       
    float modulate_gradient;       
    float modulate_curvature;       
};

uniform UniformsShading u_shading;

#endif 
