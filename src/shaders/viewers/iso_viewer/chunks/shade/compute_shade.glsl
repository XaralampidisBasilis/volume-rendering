
#include "./modules/compute_color"

#include "./modules/compute_depth"

// Compute shading vectors
vec3 light_position = u_lighting.position_offset * u_volume.size + ray.camera_position;
frag.light_vector  = light_position - trace.position;
frag.view_vector   = ray.camera_position - trace.position;
frag.normal_vector = - voxel.gradient;

// Normalize shading vectors
frag.light_vector  = normalize(frag.light_vector);
frag.normal_vector = normalize(frag.normal_vector);
frag.view_vector   = normalize(frag.view_vector);

// Compute ambient component
#include "./modules/compute_ambient"

// Compute edges fading 
#include "./modules/compute_edge"

// Compute shadows fading 
#include "./modules/compute_shadow"

// Compute diffuse component
#include "./modules/compute_diffuse"

// Compute specular component 
#include "./modules/compute_specular"

// Compute directional component
vec3 directional_component = mix(diffuse_component, specular_component, specular);
directional_component *= min(shadows_fading, edge_fading);

// Compose colors
frag.shaded_color.rgb = ambient_component + directional_component;
frag.shaded_color.rgb *= u_lighting.intensity;

// Assign frag color
fragColor = frag.shaded_color;
