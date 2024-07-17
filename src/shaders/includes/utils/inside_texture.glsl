#ifndef UTILS_INSIDE_TEXTURE
#define UTILS_INSIDE_TEXTURE

float inside_texture(in vec3 position) 
{
    vec3 s = step(0.0, position) - step(1.0, position);
    return s.x * s.y * s.z; 
}

#endif