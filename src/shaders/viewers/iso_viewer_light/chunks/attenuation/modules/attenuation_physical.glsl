// ATTENUATION_PHYSICAL

// source https://learnwebgl.brown37.net/09_lights/lights_attenuation.html
const vec3 attenuation_coefficients = vec3(1.0, 1.0, 0.0);

float light_distance = length(light_vector);
vec3 light_distance_pows = vec3(1.0, light_distance, light_distance*light_distance);

float attenuation = 1.0 / dot(attenuation_coefficients, light_distance_pows);
attenuation= clamp(mix(1.0, attenuation, u_lighting.has_attenuation), 0.0, 1.0);

