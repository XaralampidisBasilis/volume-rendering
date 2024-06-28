#ifndef UTILS_INTERSECT_BOX_MIN
#define UTILS_INTERSECT_BOX_MIN

float intersect_box_min(vec3 box_min, vec3 box_max, vec3 orig, vec3 dir) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    
    vec3 t_min_tmp = (box_min - orig) * inv_dir;
    vec3 t_max_tmp = (box_max - orig) * inv_dir;

    vec3 t_min = min(t_min_tmp, t_max_tmp);

    float t_0 = max(t_min.x, max(t_min.y, t_min.z));

    return t_0;
}

#endif