
// COMPUTE_COLORMAPPING
/**
 * Maps the trace value to a color using a colormap texture.
 *
 * @input colormap        : uniform containing colormap parameters (uniform_colormap)
 * @input u_textures.colormaps: 2d texture containing the different the colormaps (sampler2D)
 * @input trace.sample_value       : input trace value to be mapped to a color. trace value is in range [0, 1] (float)
 *
 * @output trace.mapped_color: the mapped rgb color vector corresponding to the input trace value (vec3)
 */

// scale the input trace value using the provided colormap limits 
// and posterize the result to discrete levels
float trace_mapped_value = map(u_colormap.thresholds.x, u_colormap.thresholds.y, trace_max.sample_value);
trace_mapped_value = posterize(trace_mapped_value, float(u_colormap.levels));

// interpolate the u-coordinate within the colormap texture columns
float colormap_start_coords_x = mix(u_colormap.start_coords.x, u_colormap.end_coords.x, trace_mapped_value);

// Create the UV coordinates for the texture lookup
vec2 colormap_coords = vec2(colormap_start_coords_x, u_colormap.start_coords.y);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
trace.mapped_color.rgb = texture(u_textures.colormaps, colormap_coords).rgb;
trace.mapped_color.a = pow(trace_max.sample_value, 0.3);
// trace.mapped_color.a = pow(length(trace.mapped_color.rgb), 0.3);