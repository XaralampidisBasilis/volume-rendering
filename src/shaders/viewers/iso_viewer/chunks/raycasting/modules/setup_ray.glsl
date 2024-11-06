
// Setup ray origin and direction
ray.origin_position = v_camera;
ray.step_direction = normalize(v_direction);

// Compute bounds of ray with the volume box
#include "./compute_ray_box_bounds.glsl"

// Compute intersection of ray with the volume box
#include "./compute_ray_box_intersection.glsl"

// Compute intersection of ray with the volume bounding box
#if RAY_BBOX_INTERSECTION_ENABLED == 1
#include "./compute_ray_bbox_intersection.glsl"
#endif

// Compute intersection of ray with bounding volume hierarchy
#if RAY_BVH_INTERSECTION_ENABLED == 1
#include "./compute_ray_bvh_intersection.glsl"
#endif

// Compute ray dithering
#if RAY_DITHERING_ENABLED == 1
#include "./compute_ray_start_dithering"
#endif

// Compute ray step distances 
#include "./compute_ray_step_distances"

// Compute ray step and skip counts constaints
#include "./compute_ray_max_counts"

