
// COMPUTE_COLORMAPPING
/**
 * Maps the trace value to a color using a colormap texture.
 *
 * @input u_colormap        : uniform containing colormap parameters (uniform_colormap)
 * @input u_sampler.colormap: 2d texture containing the different the colormaps (sampler2D)
 * @input trace.sample       : input trace value to be mapped to a color. trace value is in range [0, 1] (float)
 *
 * @output trace.color: the mapped rgb color vector corresponding to the input trace value (vec3)
 */

// scale the input trace value using the provided colormap limits 
// and posterize the result to discrete levels
float trace_color_value = map(u_colormap.low, u_colormap.high, trace.sample);
trace_color_value = posterize(trace_color_value, u_colormap.levels);

// interpolate the u-coordinate within the colormap texture columns
float trace_color_column = mix(u_colormap.texture_columns.x, u_colormap.texture_columns.y, trace_color_value);

// Create the UV coordinates for the texture lookup
vec2 trace_color_uv = vec2(trace_color_column, u_colormap.texture_row);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
trace.color = texture(u_sampler.colormap, trace_color_uv).rgb;

