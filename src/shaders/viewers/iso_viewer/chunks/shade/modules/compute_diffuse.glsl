// https://learnwebgl.brown37.net/09_lights/lights_diffuse.html

float lambertian = max(dot(frag.normal_vector, frag.light_vector), 0.0);

vec3 diffuse_color = lambertian 
    * u_shading.diffuse_reflectance 
    * u_lighting.diffuse_color 
    * frag.mapped_color.rgb;

// diffuse_component *= 1.0 - edge_fading;
