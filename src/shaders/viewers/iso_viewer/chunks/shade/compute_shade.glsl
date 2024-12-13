
#include "./modules/compute_mapping"

#include "./modules/compute_depth"

// Compute light position
vec3 light_offset = u_lighting.position_offset * u_volume.size;
vec3 light_position = camera.position + light_offset;

// Compute shading vectors
frag.light_vector   = light_position - trace.position;
frag.view_vector    = camera.position - trace.position;
frag.halfway_vector = frag.light_vector + frag.view_vector;

// Normalize shading vectors
frag.light_vector   = normalize(frag.light_vector);
frag.view_vector    = normalize(frag.view_vector);
frag.halfway_vector = normalize(frag.halfway_vector);

// Compute normal vector
frag.normal_vector  = normalize(voxel.gradient);
frag.normal_vector *= ssign(dot(frag.normal_vector, frag.view_vector));

// Compute vector angles
frag.light_angle   = dot(frag.light_vector, frag.normal_vector);
frag.view_angle    = dot(frag.view_vector, frag.normal_vector);
frag.halfway_angle = dot(frag.halfway_vector, frag.normal_vector);
frag.camera_angle  = dot(frag.view_vector, -camera.direction);

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
vec3 directional_color = mix(frag.diffuse_color, frag.specular_color, specular);
directional_color *= min(shadows_fading, edge_fading);

// Compose colors
frag.shaded_color.rgb = frag.ambient_color + directional_color;
frag.shaded_color.rgb *= u_lighting.intensity;

// Assign frag color
fragColor = frag.shaded_color;
