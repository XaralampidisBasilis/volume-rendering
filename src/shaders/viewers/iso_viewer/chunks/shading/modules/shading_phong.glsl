// calculate vectors
vec3 light_position = lighting.offset_position * volume.size + ray.origin_position;
vec3 light_vector = light_position - trace.position;
vec3 view_vector = ray.origin_position - trace.position;
vec3 normal_vector = trace.normal;

// Calculate attenuation frading
#include "../../attenuation/compute_attenuation"

// normalize shading vectors
light_vector = normalize(light_vector);
view_vector = normalize(view_vector);
normal_vector = normalize(normal_vector);
// normal_vector = -faceforward(normal_vector, view_vector, normal_vector); // ensure the normal points towards the viewer

// Calculate ambient component
#include "./compute_ambient"

// Calculate edge fading 
#include "./compute_edge"

// Calculate shadows fading 
#include "./compute_shadow"

// Calculate diffuse component
#include "./compute_diffuse"

// Calculate specular component 
#include "./compute_specular_phong"

// Compose the final color
vec3 directional_component = mix(diffuse_component, specular_component, specular);
directional_component *= mmin(shadows_fading, edge_fading, attenuation);

trace.shaded_color = ambient_component + directional_component;
trace.shaded_color *= lighting.intensity;


