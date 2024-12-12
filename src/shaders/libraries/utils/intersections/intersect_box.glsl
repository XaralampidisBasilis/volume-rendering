// Ray-AABB (Axis Aligned Bounding Box) intersection.
// Mathematics: https://tavianator.com/2022/ray_box_boundary.html
// box: https://iquilezles.org/articles/intersectors/

#ifndef INTERSECT_BOX
#define INTERSECT_BOX

#ifndef MMIN
#include "../mmin"
#endif
#ifndef MMAX
#include "../mmax"
#endif

vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    float t_entry = mmax(t_min);
    float t_exit = mmin(t_max);
    return vec2(t_entry, t_exit);
}

vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 entry_position, out vec3 exit_position) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    float t_entry = mmax(t_min);
    float t_exit  = mmin(t_max);
    entry_position = start + dir * t_entry;
    exit_position = start + dir * t_exit;   
    return vec2(t_entry, t_exit);
}


vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 entry_position, out vec3 exit_position, out vec3 entry_normal, out vec3 exit_normal) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    float t_entry = mmax(t_min);
    float t_exit  = mmin(t_max);
    vec3 dir_sign = sign(dir);
    entry_position = start + dir * t_entry;
    exit_position = start + dir * t_exit;   
    entry_normal = step(vec3(t_entry), t_min) * dir_sign;
    exit_normal = step(t_max, vec3(t_exit)) * -dir_sign;    
    return vec2(t_entry, t_exit);
}

#endif 