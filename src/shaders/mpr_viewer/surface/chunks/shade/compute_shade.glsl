

// Compute scene vectors, angles 
#include "./modules/compute_scene"

// Compute ambient component
#include "./modules/compute_ambient"

// Compute diffuse component
#include "./modules/compute_diffuse"

// Compute specular component 
#include "./modules/compute_specular"

// Compute shaded color
vec3 directional_color = mix(frag.diffuse_color, frag.specular_color, specular);
frag.shaded_color.rgb = frag.ambient_color + directional_color;

// Assign frag color
fragColor = frag.shaded_color;
gl_FragDepth = frag.depth;
