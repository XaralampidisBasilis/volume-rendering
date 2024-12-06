// calculate vectors
vec3 light_position = u_lighting.position_offset * u_volume.size + ray.camera_position;
vec3 light_vector = light_position - trace.position;
vec3 view_vector = ray.camera_position - trace.position;
vec3 normal_vector = -voxel.gradient;

// normalize shading vectors
normal_vector = normalize(normal_vector);
light_vector  = normalize(light_vector);
view_vector   = normalize(view_vector);

// Calculate ambient component
#include "./modules/compute_ambient"

// Calculate edges fading 
#include "./modules/compute_edge"

// Calculate shadows fading 
#include "./modules/compute_shadow"

// Calculate diffuse component
#include "./modules/compute_diffuse"

// Calculate specular component 
#include "./modules/compute_specular"

// Compose the final color
vec3 directional_component = mix(diffuse_component, specular_component, specular);
directional_component *= min(shadows_fading, edge_fading);

trace.shaded_color.rgb = ambient_component + directional_component;
trace.shaded_color.rgb *= u_lighting.intensity;
