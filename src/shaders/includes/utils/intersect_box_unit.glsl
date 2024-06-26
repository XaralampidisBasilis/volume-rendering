#ifndef UTILS_INTERSECT_BOX_UNIT
#define UTILS_INTERSECT_BOX_UNIT

vec2 intersect_box_unit(vec3 orig, vec3 dir) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    
    vec3 t_min_tmp = (0.0 - orig) * inv_dir;
    vec3 t_max_tmp = (1.0 - orig) * inv_dir;

    vec3 t_min = min(t_min_tmp, t_max_tmp);
    vec3 t_max = max(t_min_tmp, t_max_tmp);

    float t_0 = max(t_min.x, max(t_min.y, t_min.z));
    float t_1 = min(t_max.x, min(t_max.y, t_max.z));

    return vec2(t_0, t_1);
}

#endif