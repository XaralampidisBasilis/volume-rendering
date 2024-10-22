ray.origin = v_camera;
ray.direction = normalize(v_direction);

// compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
#include "./modules/compute_distances"

// compute the ray step vector based on the raycast and volume parameters.
#include "../spacing/compute_spacing"
ray.max_steps = int(ray.max_depth / ray.min_spacing);
ray.max_steps = min(ray.max_steps, u_raycast.max_steps);

// apply dithering to the initial distance to avoid artifacts.
#include "../dithering/compute_dithering"
ray.max_depth += ray.dithering;

// initialize trace starting position along the ray.
trace.distance = ray.min_distance - ray.dithering;
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * u_volume.inv_size;
trace.spacing = ray.spacing;
trace.stepping = u_raycast.min_stepping;

// raycasting loop to traverse through the volume and find intersections.
#include "../raymarch/compute_raymarch"
#include "../refinement/compute_refinement"
#include "../gradient/compute_gradient"
#include "../smoothing/compute_smoothing"



