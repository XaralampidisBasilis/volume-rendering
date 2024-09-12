#ifndef UTILS_INSIDE_BOX
#define UTILS_INSIDE_BOX

float inside_box(in vec3 box_min, vec3 box_max, in vec3 position) 
{
    vec3 s = step(box_min - 1e-6, position) * step(position, box_max + 1e-6);
    return s.x * s.y * s.z; 
}

#endif