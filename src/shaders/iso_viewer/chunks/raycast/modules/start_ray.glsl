// Compute normalized direction 
ray.direction = normalize(v_ray_direction);
ray.inv_direction = 1.0 / ray.direction;

// Compute the octant sign of the direction 
ray.signs = ivec3(ssign(ray.direction));

// Compute 3-bit octant index (0–7) based on sign bits
ivec3 bits = ivec3(greaterThan(ray.signs, ivec3(0)));
ray.octant = (bits.z << 2) | (bits.y << 1) | (bits.x << 0);

// Compute directional mean cell spacing 
// For a specific ray direction, this result is the 
// mean span distance that a ray passes from a cell. 
ray.spacing = 1.0 / sum(abs(ray.direction));
