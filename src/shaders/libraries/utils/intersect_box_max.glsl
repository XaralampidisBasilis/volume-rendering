#ifndef INTERSECT_BOX_MAX
#define INTERSECT_BOX_MAX

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_max = max(t_min_tmp, t_max_tmp);
    float t_exit = mmin(t_max);
    return t_exit;
}

float intersect_box_max(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 normal_exit) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 t_min_tmp = (box_min - start) * inv_dir;
    vec3 t_max_tmp = (box_max - start) * inv_dir;
    vec3 t_max = max(t_min_tmp, t_max_tmp);
    float t_exit = mmin(t_max);
    normal_exit = step(t_max, vec3(t_exit)) * -sign(dir);
    return t_exit;
}

#endif // INTERSECT_BOX_MAX