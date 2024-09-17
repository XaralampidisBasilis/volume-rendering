// ATTENUATION_SMOOTHSTEP

vec2 light_box_distances = reach_box(ray.box_min, ray.box_max, light_position);
float light_mapped_depth = map(light_box_distances.x, light_box_distances.y, length(light_vector));

float attenuation = 1.0 - smoothstep(0.0, 1.0, light_mapped_depth);
attenuation = mix(1.0, attenuation, u_shading.attenuation);