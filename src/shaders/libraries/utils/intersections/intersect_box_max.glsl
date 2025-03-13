// Ray-AABB (Axis Aligned Bounding Box) intersection.
// Mathematics: https://tavianator.com/2022/ray_box_boundary.html
// https://www.scratchapixel.com/lessons/3d-basic-rendering/minimal-ray-tracer-rendering-simple-shapes/ray-box-intersection.html

#ifndef INTERSECT_BOX_MAX
#define INTERSECT_BOX_MAX


#ifndef MILLI_TOLERANCE
#define MILLI_TOLERANCE 1e-3
#endif
#ifndef MMIN
#include "../math/mmin"
#endif
#ifndef ARGMIN
#include "../math/argmin"
#endif

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 s_min = (box_min - start) * inv_dir;
    vec3 s_max = (box_max - start) * inv_dir;
    vec3 t_max = max(s_min, s_max);
    float t_exit = mmin(t_max);
    return t_exit;
}

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out int axis) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 s_min = (box_min - start) * inv_dir;
    vec3 s_max = (box_max - start) * inv_dir;
    vec3 t_max = max(s_min, s_max);
    float t_exit = mmin(t_max);
    axis = argmin(t_max);
    return t_exit;
}

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out ivec3 axes) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 s_min = (box_min - start) * inv_dir;
    vec3 s_max = (box_max - start) * inv_dir;
    vec3 t_max = max(s_min, s_max);
    float t_exit = mmin(t_max);
    axes  = ivec3(lessThan(t_max - t_exit, vec3(MILLI_TOLERANCE))); 
    return t_exit;
}


#endif // INTERSECT_BOX_MAX