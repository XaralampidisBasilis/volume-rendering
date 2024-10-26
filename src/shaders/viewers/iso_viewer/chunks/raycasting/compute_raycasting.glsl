

#include "./modules/setup_occumap"
#include "./modules/setup_ray"

// skip initial volume empty space 
#include "../skipping/compute_skipping"

// compute the ray step vector based on the raycast and volume parameters.
#include "../spacing/compute_spacing"
ray.max_steps = int(ray.max_depth / ray.min_spacing);
ray.max_steps = min(ray.max_steps, u_raycast.max_steps);

// apply dithering to the initial distance to avoid artifacts.
#include "../dithering/compute_dithering"
ray.max_depth += ray.dithering;

// initialize trace starting position along the ray.
trace.distance -= ray.dithering;
trace.position = ray.origin + ray.direction * trace.distance;
trace.texel = trace.position * volume_inv_size;
trace.spacing = ray.spacing;
trace.stepping = u_raycast.min_stepping;

// raycasting loop to traverse through the volume and find intersections.
#include "../raymarch/compute_raymarch"

// apply last refinements 
#include "../refinement/compute_refinement"
#include "../gradient/compute_gradient"



