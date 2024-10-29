// ATTENUATION_SMOOTHSTEP

vec2 box_distance = sdf_box_bounds(ray.min_start_position, ray.min_end_position, light_position);
float light_distance = distance(light_position, trace.position);

float attenuation = 1.0 - softstep(box_distance.x, box_distance.y, light_distance);
attenuation = mix(1.0, attenuation, lighting.LIGHTING_ATTENUATION_ENABLED);
