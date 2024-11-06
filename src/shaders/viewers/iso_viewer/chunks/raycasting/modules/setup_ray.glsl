
// Compute ray origin and direction
ray.origin_position = v_camera;
ray.step_direction = normalize(v_direction);

// Compute bounds of ray with the volume box
#include "./compute_ray_box_bounds.glsl"

// Compute intersection of ray with the volume box
#include "./compute_ray_box_intersection.glsl"

// Compute intersection of ray with the volume bounding box
#include "./compute_ray_bbox_intersection.glsl"

// Compute intersection of ray with bounding volume hierarchy
#include "./compute_ray_bvh_intersection.glsl"

// Compute ray step distances 
#include "./compute_ray_step_distances"

// Compute ray dithering
#include "./compute_ray_start_dithering"

// Compute ray step and skip counts constaints
#include "./compute_ray_iterator_constraints"

