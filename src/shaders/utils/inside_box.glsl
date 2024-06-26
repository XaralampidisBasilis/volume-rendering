float inside_box(in vec3 box_min, vec3 box_max, in vec3 position) 
{
    vec3 s = step(box_min, position) - step(box_max, position);
    return s.x * s.y * s.z; 
}