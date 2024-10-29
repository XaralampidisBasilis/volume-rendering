// ATTENUATION_SMOOTHSTEP

vec2 box_distance = box_bounds(ray.start_position, ray.end_position, light_position);
float light_distance = distance(light_position, trace.position);

float attenuation = 1.0 - softstep(box_distance.x, box_distance.y, light_distance);
