
// Set step coords
block.step_coords = ivec3(0);

// Compute block coords
block.coords = ivec3((ray.end_position + u_volume.spacing * 0.5) * u_extremap.inv_spacing);

