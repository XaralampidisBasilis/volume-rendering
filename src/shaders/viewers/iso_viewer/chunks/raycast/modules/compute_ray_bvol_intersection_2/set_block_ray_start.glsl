
// Compute block coords
block.step_coords = ivec3(0);
block.coords = ivec3((ray.start_position + u_volume.spacing * 0.5) * u_distmap.inv_spacing);

