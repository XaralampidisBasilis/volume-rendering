#ifndef UTILS_INSIDE_UNIBOX
#define UTILS_INSIDE_UNIBOX

float inside_unibox(in vec3 position) 
{
    vec3 s = step(vec3(0.0), position) * step(position, vec3(1.0));
    return s.x * s.y * s.z; 
}

#endif // UTILS_INSIDE_UNIBOX