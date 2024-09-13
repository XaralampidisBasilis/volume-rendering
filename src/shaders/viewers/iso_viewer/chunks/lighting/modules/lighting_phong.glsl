// calculate vectors
vec3 light_position = u_lighting.position * u_volume.size + ray.origin;
vec3 light_vector = light_position - trace.position;
vec3 view_vector = ray.origin - trace.position;
vec3 normal_vector = trace.normal;

// Calculate attenuation frading
float attenuation;
#include "./compute_attenuation"

// normalize lighting vectors
light_vector = normalize(light_vector);
view_vector = normalize(view_vector);
normal_vector = normalize(normal_vector);
// normal_vector = -faceforward(normal_vector, view_vector, normal_vector); // ensure the normal points towards the viewer

// Calculate ambient component
vec3 ambient_component;
#include "./compute_ambient"

// Calculate edge fading 
float edge_fading;
#include "./compute_edge"

// Calculate diffuse component
float lambertian;
vec3 diffuse_component;
#include "./compute_diffuse"

// Calculate specular component 
float specular;
vec3 specular_component;
#include "./compute_specular_phong"

// Compose the final color
vec3 directional_component = mix(diffuse_component, specular_component, specular);
directional_component *= 1.0 - edge_fading;
directional_component *= attenuation_fading;

trace.shading = ambient_component + directional_component;
trace.shading *= u_lighting.power;


