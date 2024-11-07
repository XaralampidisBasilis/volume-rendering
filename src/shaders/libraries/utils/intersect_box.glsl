#ifndef INTERSECT_BOX
#define INTERSECT_BOX

vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    return vec2(mmax(t_min), mmin(t_max));
}

vec2 intersect_box(in vec3 box_min, in vec3 box_max, in vec3 start, in vec3 dir, out vec3 pos_min, out vec3 pos_max) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html

    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 p_min = min(b_min, b_max);
    vec3 p_max = max(b_min, b_max);
    float t_min = mmax(p_min);
    float t_max = mmin(p_max);
    pos_min = start + dir * t_min;
    pos_max = start + dir * t_max;
    return vec2(t_min, t_max);
}


vec2 intersect_box(vec3 box_min, vec3 box_max, vec3 start, vec3 dir, out vec3 normal) 
{
    // Ray-AABB (Axis Aligned Bounding Box) intersection.
    // Mathematics: https://tavianator.com/2022/ray_box_boundary.html
    // box: https://iquilezles.org/articles/intersectors/

    vec3 inv_dir = 1.0 / dir;
    vec3 b_min = (box_min - start) * inv_dir;
    vec3 b_max = (box_max - start) * inv_dir;
    vec3 t_min = min(b_min, b_max);
    vec3 t_max = max(b_min, b_max);
    float t_near = mmax(t_min);
    float t_far  = mmin(t_max);
    if (t_near > t_far || t_far < 0.0) return vec2(-1.0); // no intersection

    normal = (t_near > 0.0) ? step(vec3(t_near), t_min) : step(t_max, vec3(t_far));  
    normal = normalize(normal);
    normal *= -sign(dir);

    return vec2(t_near, t_far);
}


#endif // INTERSECT_BOX