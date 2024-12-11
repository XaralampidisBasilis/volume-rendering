
// COMPUTE_COLORMAPPING
/**
 * Maps the trace value to a color using a colormap texture.
 *
 * @input colormap        : uniform containing colormap parameters (uniform_colormap)
 * @input u_textures.color_maps: 2d texture containing the different the color_maps (sampler2D)
 * @input trace.value       : input trace value to be mapped to a color. trace value is in range [0, 1] (float)
 *
 * @output trace.mapped_color: the mapped rgb color vector corresponding to the input trace value (vec3)
 */

// Map voxel value
frag.mapped_value = map(u_colormap.thresholds.x, u_colormap.thresholds.y, proj_voxel.value);

// Posterize to discrete levels
frag.mapped_value = posterize(frag.mapped_value, float(u_colormap.levels));

// interpolate the u-coordinate within the colormap texture columns
float colormap_coords_x = mix(u_colormap.start_coords.x, u_colormap.end_coords.x, frag.mapped_value);
float colormap_coords_y = u_colormap.start_coords.y;

// Create the UV coordinates for the texture lookup
vec2 colormap_coords = vec2(colormap_coords_x, colormap_coords_y);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
frag.mapped_color.rgb = texture(u_textures.color_maps, colormap_coords).rgb;

