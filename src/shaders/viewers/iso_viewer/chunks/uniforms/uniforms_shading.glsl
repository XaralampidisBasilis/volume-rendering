#ifndef UNIFORMS_SHADING
#define UNIFORMS_SHADING

struct Shading
{
    float ambient_reflectance; 
    float diffuse_reflectance; 
    float specular_reflectance;
    float shininess;           
    float edge_contrast;       
};

uniform Shading u_shading;

#endif // UNIFORMS_SHADING
