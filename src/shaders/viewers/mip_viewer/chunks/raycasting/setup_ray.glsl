
// Setup ray origin and direction
ray.camera_position = v_camera_position;
ray.camera_direction = normalize(v_camera_direction);
ray.step_direction = normalize(v_ray_direction);

// Compute intersection of ray with the volume box
#include "./modules/compute_ray_box_intersection.glsl"

// Compute bounds of ray with the volume box
#include "./modules/compute_ray_distance_bounds.glsl"

// Compute intersection of ray with the extrema occupancy max for maximum intensity projection
#include "./modules/compute_ray_extremap_intersection/compute_ray_extremap_intersection.glsl"

// Compute ray step distances 
#include "./modules/compute_ray_step_distances"

// Compute ray dithering
#if RAY_DITHERING_ENABLED == 1
#include "./modules/compute_ray_dithering"
#endif

// coumpute the maximum allowed number of steps based on the min ray step distance
ray.max_step_count = int(ceil(ray.span_distance / ray.min_step_distance));
ray.max_step_count = mmin(ray.max_step_count, u_raymarch.max_step_count, MAX_STEP_COUNT);


