
vec2 b_bounds = bounds_box(ray.box_min, ray.box_max, ray.origin);
float b_max_depth = b_bounds.y - b_bounds.x;

vec4(vec3((trace.distance - b_bounds.x) / b_max_depth), 1.0);