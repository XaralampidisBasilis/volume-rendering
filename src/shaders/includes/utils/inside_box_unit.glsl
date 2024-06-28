#ifndef UTILS_INSIDE_BOX_UNIT
#define UTILS_INSIDE_BOX_UNIT

float inside_box_unit(in vec3 position) 
{
    vec3 s = step(0.0, position) - step(1.0, position);
    return s.x * s.y * s.z; 
}

#endif