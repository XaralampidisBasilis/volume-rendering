// source https://learnwebgl.brown37.net/09_lights/lights_attenuation.html

// attenuation parameters
const float c1 = 0.0;
const float c2 = 0.8;
const float c3 = 0.3;
float distance = length(light_vector);
attenuation = 1.0 / (c1 + c2 * distance + c3 * distance * distance);
attenuation = clamp( attenuation, 0.0, 1.0);
attenuation = mix(1.0, attenuation, u_lighting.attenuation);

