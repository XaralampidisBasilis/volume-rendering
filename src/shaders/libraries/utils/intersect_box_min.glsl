#ifndef INTERSECT_BOX_MIN
#define INTERSECT_BOX_MIN

#ifndef MMIN
#include "./mmin"
#endif

#ifndef MMAX
#include "./mmax"
#endif

float intersect_box_min(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_min = min(t_min_tmp, t_max_tmp);
    float t_entry = mmax(t_min);
    return t_entry;
}

float intersect_box_min(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 entry_position) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_min = min(t_min_tmp, t_max_tmp);
    float t_entry = mmax(t_min);
    entry_position = start + dir * t_entry;
    return t_entry;
}

float intersect_box_min(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 entry_position, out vec3 entry_normal) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_min = min(t_min_tmp, t_max_tmp);
    float t_entry = mmax(t_min);
    entry_position = start + dir * t_entry;
    entry_normal = step(vec3(t_entry), t_min) * sign(dir);
    return t_entry;
}

#endif // INTERSECT_BOX_MIN