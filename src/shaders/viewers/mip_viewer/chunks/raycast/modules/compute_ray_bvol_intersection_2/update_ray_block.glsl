
// Compute block coords from trace position
block.coords += block.step_coords;

// Compute block min max position in model space  
block.min_position = vec3(block.coords + 0) * u_extremap.spacing - u_volume.spacing * 0.5;
block.max_position = vec3(block.coords + 1) * u_extremap.spacing - u_volume.spacing * 0.5;  

// Compute block extrema values
vec2 extrema_data = texelFetch(u_textures.extrema_map, block.coords, 0).rg;
block.min_value = extrema_data.r; 
block.max_value = extrema_data.g; 

// Compute block occupancy
block.occupied = ray.min_value < block.max_value;
