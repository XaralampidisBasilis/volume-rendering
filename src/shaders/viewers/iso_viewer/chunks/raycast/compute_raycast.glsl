
// Setup ray
ray.step_direction = normalize(v_ray_direction);
ray.camera_direction = normalize(v_camera_direction);
ray.camera_position = v_camera_position;

// Compute intersection of ray with volume box
#include "./modules/compute_ray_box_intersection.glsl"

// Compute bounds of ray with volume box
#include "./modules/compute_ray_box_bounds.glsl"

// Compute intersection of ray with bounding box
#if RAY_INTERSECT_BBOX_ENABLED == 1
#include "./modules/compute_ray_bbox_intersection.glsl"
#endif

// Compute intersection of ray with bounding volume
#if RAY_INTERSECT_BVOL_ENABLED == 1
#include "./modules/compute_ray_bvol_intersection.glsl"
#endif

// Compute ray step distance
#include "./modules/compute_ray_step_distance"

// Compute ray max steps 
#include "./modules/compute_ray_max_steps"

// Compute ray dithering
#if RAY_DITHERING_ENABLED == 1
#include "./modules/compute_ray_dithering"
#endif

// Compute ray march through the volume
#include "../march/compute_march"





