
// Setup ray origin and direction
ray.camera_position = v_camera_position;
ray.camera_direction = normalize(v_camera_direction);
ray.step_direction = normalize(v_ray_direction);

// Compute ray step and skip counts constaints
#include "./modules/compute_ray_max_counts"

// Compute bounds of ray with the volume box
#include "./modules/compute_ray_distance_bounds.glsl"

// Compute intersection of ray with the volume box
#include "./modules/compute_ray_box_intersection.glsl"

// Compute intersection of ray with the volume bounding box
#if RAY_BBOX_INTERSECTION_ENABLED == 1
#include "./modules/compute_ray_bbox_intersection.glsl"
#endif

// Compute intersection of ray with bounding volume hierarchy
#if RAY_BVH_INTERSECTION_ENABLED == 1
#include "./modules/compute_ray_bvh_intersection/compute_ray_bvh_intersection.glsl"
#endif

// Compute ray step distances 
#include "./modules/compute_ray_step_distances"

// Compute ray dithering
#if RAY_DITHERING_ENABLED == 1
#include "./modules/compute_ray_dithering"
#endif


