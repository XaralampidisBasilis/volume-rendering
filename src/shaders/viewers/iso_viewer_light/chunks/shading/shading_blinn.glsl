// calculate vectors
vec3 light_position = u_lighting.offset_position * u_volume.size + ray.origin;
vec3 light_vector = light_position - trace.position;
vec3 view_vector = ray.origin - trace.position;
vec3 normal_vector = trace.normal;

// Calculate attenuation frading
#include "./modules/compute_attenuation"

// normalize shading vectors
light_vector = normalize(light_vector);
view_vector = normalize(view_vector);
normal_vector = normalize(normal_vector);
// normal_vector = -faceforward(normal_vector, view_vector, normal_vector); // ensure the normal points towards the viewer

// Calculate ambient component
#include "./modules/compute_ambient"

// Calculate edges fading 
#include "./modules/compute_edge"

// Calculate shadows fading 
#include "./modules/compute_shadow"

// Calculate diffuse component
#include "./modules/compute_diffuse"

// Calculate specular component 
#include "./modules/compute_specular_blinn"

// Compose the final color
vec3 directional_component = mix(diffuse_component, specular_component, specular);
directional_component *= mmin(shadows_fading, edge_fading, attenuation);

trace.shading = ambient_component + directional_component;
trace.shading *= u_lighting.power;
