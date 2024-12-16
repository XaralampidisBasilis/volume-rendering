// Ray-AABB (Axis Aligned Bounding Box) intersection.
// Mathematics: https://tavianator.com/2022/ray_box_boundary.html

#ifndef INTERSECT_BOX_MAX
#define INTERSECT_BOX_MAX

#ifndef MMIN
#include "../mmin"
#endif
#ifndef MMAX
#include "../mmax"
#endif

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_max = max(t_min_tmp, t_max_tmp);
    float t_exit = mmin(t_max);
    return t_exit;
}

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out ivec3 exit_face) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_max = max(t_min_tmp, t_max_tmp);
    float t_exit = mmin(t_max);
    vec3 s_exit = sign(dir);
    vec3 f_exit = step(t_max, vec3(t_exit)) * s_exit;
    exit_face = ivec3(f_exit);
    return t_exit;
}

#endif // INTERSECT_BOX_MAX