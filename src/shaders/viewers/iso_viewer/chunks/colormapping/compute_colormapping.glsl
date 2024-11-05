
// COMPUTE_COLORMAPPING
/**
 * Maps the trace value to a color using a colormap texture.
 *
 * @input colormap        : uniform containing colormap parameters (uniform_colormap)
 * @input textures.colormaps: 2d texture containing the different the colormaps (sampler2D)
 * @input trace.sample_value       : input trace value to be mapped to a color. trace value is in range [0, 1] (float)
 *
 * @output trace.mapped_color: the mapped rgb color vector corresponding to the input trace value (vec3)
 */

// scale the input trace value using the provided colormap limits 
// and posterize the result to discrete levels
float trace_mapped_value = map(colormap.thresholds.x, colormap.thresholds.y, trace.sample_value);
trace_mapped_value = posterize(trace_mapped_value, float(colormap.levels));

// interpolate the u-coordinate within the colormap texture columns
float colormap_start_coords_x = mix(colormap.start_coords.x, colormap.end_coords.x, trace_mapped_value);

// Create the UV coordinates for the texture lookup
vec2 colormap_coords = vec2(colormap_start_coords_x, colormap.start_coords.y);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
trace.mapped_color.rgb = texture(textures.colormaps, colormap_coords).rgb;

