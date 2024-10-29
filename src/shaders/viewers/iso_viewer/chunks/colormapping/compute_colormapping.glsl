
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
float trace_color_value = map(colormap.thresholds.x, colormap.thresholds.y, trace.sample_value);
trace_color_value = posterize(trace_color_value, colormap.levels);

// interpolate the u-coordinate within the colormap texture columns
float trace_color_column = mix(colormap.start_coords.x, colormap.end_coords.y, trace_color_value);

// Create the UV coordinates for the texture lookup
vec2 trace_color_uv = vec2(trace_color_column, colormap.start_coords.y);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
trace.mapped_color = texture(textures.colormaps, trace_color_uv).rgb;

