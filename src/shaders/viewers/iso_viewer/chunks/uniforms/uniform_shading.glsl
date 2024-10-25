#ifndef UNIFORM_SHADING
#define UNIFORM_SHADING

struct Shading
{
    float ambient_reflectance; 
    float diffuse_reflectance; 
    float specular_reflectance;
    float shininess;           
    float edge_contrast;       
};

#endif // UNIFORM_SHADING
