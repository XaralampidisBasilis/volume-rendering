#ifndef INTERSECT_BOX
#define INTERSECT_BOX

vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_min = min(t_min_tmp, t_max_tmp);
    vec3 t_max = max(t_min_tmp, t_max_tmp);
    return vec2(mmax(t_min), mmin(t_max));
}

#endif // INTERSECT_BOX