
// Compute block coords from trace position
block.coords = ivec3(trace.position * u_extremap.inv_spacing);
block.texture_coords = ray.start_position * u_extremap.inv_size;

// Compute block min max positions in model space  
block.min_position = (vec3(block.coords + 0) - MILLI_TOLERANCE) * u_extremap.spacing;
block.max_position = (vec3(block.coords + 1) + MILLI_TOLERANCE) * u_extremap.spacing;

// Sample extremap map and compute block occupation
// vec2 texture_data = texture(u_textures.extrema_map, block.texture_coords).rg;
vec2 texture_data = texelFetch(u_textures.extrema_map, block.coords, 0).rg;
block.min_value = texture_data.r; 
block.max_value = texture_data.g; 
