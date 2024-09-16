// source https://learnwebgl.brown37.net/09_lights/lights_attenuation.html

// attenuation parameters
const vec3 c_attenuation = vec3(1.0, 0.1, 0.0);
float light_distance = length(light_vector) - ray.min_box_distance;
vec3 light_distance_pows = vec3(1.0, light_distance, light_distance * light_distance);
attenuation = 1.0 / dot(c_attenuation, light_distance_pows);
attenuation = clamp(attenuation, 0.0, 1.0);
attenuation = mix(1.0, attenuation, u_lighting.attenuation);

