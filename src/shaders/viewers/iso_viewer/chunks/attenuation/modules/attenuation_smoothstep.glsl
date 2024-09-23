// ATTENUATION_SMOOTHSTEP

vec2 box_distance = reach_box(ray.box_min, ray.box_max, light_position);
float light_distance = distance(light_position, trace.position);

float attenuation = 1.0 - softstep(box_distance.x, box_distance.y, light_distance);
attenuation = mix(1.0, attenuation, u_shading.attenuation);
