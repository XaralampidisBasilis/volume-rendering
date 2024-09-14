// COMPUTE_COLORMAPPING

/**
 * Maps the trace value to a color using a colormap texture.
 *
 * @input u_colormap : uniform containing colormap parameters
 * @input u_sampler.colormap : 2d texture containing the different the colormaps
 * @input trace.value : input trace value to be mapped to a color. trace value is in range [0, 1]
 * @output trace.color: the mapped rgb color vector corresponding to the input trace value
 */

// scale the input trace value using the provided colormap limits 
// and posterize the result to discrete levels
float color_value = map(u_colormap.low, u_colormap.high, trace.value);
color_value = posterize(color_value, u_colormap.levels);

// interpolate the u-coordinate within the colormap texture columns
float color_u = mix(u_colormap.texture_columns.x, u_colormap.texture_columns.y, color_value);

// Create the UV coordinates for the texture lookup
vec2 color_uv = vec2(color_u, u_colormap.texture_row);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
trace.color = texture(u_sampler.colormap, color_uv).rgb;

