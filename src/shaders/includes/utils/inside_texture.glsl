#ifndef UTILS_INSIDE_TEXTURE
#define UTILS_INSIDE_TEXTURE

float inside_texture(in vec3 position) 
{
    vec3 s = step(vec3(0.0), position) * step(position, vec3(1.0));
    return s.x * s.y * s.z; 
}

#endif