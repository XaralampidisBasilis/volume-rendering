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

vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 entry_normal, out vec3 exit_normal) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    float t_entry = mmax(t_min);
    float t_exit  = mmin(t_max);
    vec3 d_sign = sign(dir);
    entry_normal = step(vec3(t_entry), t_min) * -d_sign;
    exit_normal = step(t_max, vec3(t_exit)) * d_sign;    
    return vec2(t_entry, t_exit);
}

vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out ivec3 entry_step, out ivec3 exit_step) 
{
    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    float t_entry = mmax(t_min);
    float t_exit  = mmin(t_max);
    vec3 d_sign = sign(dir);
    vec3 n_entry = step(vec3(t_entry), t_min) * -d_sign;
    vec3 n_exit = step(t_max, vec3(t_exit)) * d_sign;  
    entry_step = ivec3(n_entry);
    exit_step = ivec3(n_exit);
    return vec2(t_entry, t_exit);
}

#endif 