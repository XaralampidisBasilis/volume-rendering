
// Scale the input value 'ray_value' using the provided limits
float color_value = map(u_colormap.low, u_colormap.high, trace.value);

// Posterize the scaled ray sample to discrete levels
color_value = posterize(color_value, u_colormap.levels);

// Interpolate the u-coordinate within the colormap texture range
color_value = mix(u_colormap.texture_columns.x, u_colormap.texture_columns.y, color_value);

// Create the UV coordinates for the texture lookup
vec2 color_uv = vec2(color_value, u_colormap.texture_row);

// Sample the colormap texture at the calculated UV coordinates and return the RGB color
trace.color = texture(u_sampler.colormap, color_uv).rgb;

