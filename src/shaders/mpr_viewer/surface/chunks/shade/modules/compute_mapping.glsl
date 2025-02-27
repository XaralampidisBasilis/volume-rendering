
// Map voxel value
frag.mapped_intensity = map(u_color_map.thresholds.x, u_color_map.thresholds.y, trace.intensity);

// Posterize to discrete levels
frag.mapped_intensity = posterize(frag.mapped_intensity, float(u_color_map.levels));

// interpolate the u-coordinate within the colormap texture columns
float colormap_coords_x = mix(u_color_map.start_coords.x, u_color_map.end_coords.x, frag.mapped_intensity);
float colormap_coords_y = u_color_map.start_coords.y;

// Create the UV coordinates for the texture lookup
vec2 colormap_coords = vec2(colormap_coords_x, colormap_coords_y);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
frag.mapped_color.rgb = texture(u_textures.color_maps, colormap_coords).rgb;

