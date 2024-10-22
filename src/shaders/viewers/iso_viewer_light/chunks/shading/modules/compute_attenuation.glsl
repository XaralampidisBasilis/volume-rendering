
vec2 box_distance = sdf_box_bounds(ray.global_min_position, ray.global_max_position, light_position);
float light_distance = distance(light_position, trace.position);

float attenuation = 1.0 - softstep(box_distance.x, box_distance.y, light_distance);
attenuation = mix(1.0, attenuation, u_lighting.has_attenuation);
