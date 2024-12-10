
#include "./modules/compute_mapping"

#include "./modules/compute_depth"

// Compute shading vectors
frag.view_vector    = camera.position - trace.position;
frag.normal_vector  = - voxel.gradient;

// Normalize shading vectors
frag.view_vector    = normalize(frag.view_vector);
frag.normal_vector  = normalize(frag.normal_vector);

// Compute vector angles
frag.view_angle    = dot(frag.view_vector, frag.normal_vector);
frag.camera_angle  = dot(frag.view_vector, -camera.direction);

// Assign frag color
fragColor = frag.mapped_color;
