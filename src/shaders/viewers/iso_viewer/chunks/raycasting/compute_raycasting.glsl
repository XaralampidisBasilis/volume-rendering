// compute the intersection bounds of a ray with the occupancy axis-aligned bounding box.
#include "./modules/compute_bounds"
ray.max_depth = max(ray.max_distance - ray.min_distance, 0.0);

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
trace.spacing = ray.spacing;

// raycasting loop to traverse through the volume and find intersections.
#include "../raymarch/compute_raymarch"
#include "../refinement/compute_refinement"

trace.coords = floor(trace.position * u_volume.inv_spacing);
trace.depth = trace.distance - ray.min_distance;
trace.traversed = trace.depth - trace.skipped;



