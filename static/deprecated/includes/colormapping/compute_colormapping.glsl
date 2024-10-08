/**
 * Maps a float value to a color using a 2D colormap texture.
 *
 * @param u_colormap Uniform containing colormap parameters
 * @param colormap 2D texture representing the colormap
 * @param ray_value Input value to be mapped to a color
 * @return vec3 The RGB color corresponding to the input value
 */
vec3 compute_colormapping
(
    in uniforms_colormap u_colormap, 
    in sampler2D colormap, 
    in float value
) 
{
    // Scale the input value 'ray_value' using the provided limits
    value = map(u_colormap.low, u_colormap.high, value);

    // Posterize the scaled ray sample to discrete levels
    value = posterize(value, u_colormap.levels);
    
    // Interpolate the u-coordinate within the colormap texture range
    value = mix(u_colormap.texture_columns.x, u_colormap.texture_columns.y, value);

    // Create the UV coordinates for the texture lookup
    vec2 uv = vec2(value, u_colormap.texture_row);
    
    // Sample the colormap texture at the calculated UV coordinates and return the RGB color
    return texture(colormap, uv).rgb;
}
