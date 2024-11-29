#ifndef UNIFORM_LIGHTING
#define UNIFORM_LIGHTING

struct Lighting 
{
    float intensity;          
    float shadows;            
    vec3  ambient_color;      
    vec3  diffuse_color;      
    vec3  specular_color;     
    vec3  position_offset;    
};

uniform Lighting u_lighting;

#endif // UNIFORM_LIGHTING
