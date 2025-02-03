// https://learnwebgl.brown37.net/09_lights/lights_diffuse.html

float lambertian = max(frag.light_angle, 0.0);

frag.diffuse_color = lambertian 
    * u_shading.diffuse_reflectance 
    * u_lighting.diffuse_color 
    * frag.mapped_color.rgb;
