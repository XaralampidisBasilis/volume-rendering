/**
 * Maps a float value to a color using a 2D colormap texture.
 *
 * @param u_colormap Uniform containing colormap parameters
 * @param colormap 2D texture representing the colormap
 * @param ray_value Input value to be mapped to a color
 * @return vec3 The RGB color corresponding to the input value
 */
vec3 compute_color
(
    in uniforms_colormap u_colormap, 
    in sampler2D colormap, 
    in float ray_value
) 
{
    // Scale the input value 'ray_value' using the provided limits
    ray_value = rampstep(u_colormap.low, u_colormap.high, ray_value);

    // Posterize the scaled ray sample to discrete levels
    ray_value = posterize(ray_value, u_colormap.levels);
    
    // Interpolate the u-coordinate within the colormap texture range
    ray_value = mix(u_colormap.texture_range.x, u_colormap.texture_range.y, ray_value);

    // Create the UV coordinates for the texture lookup
    vec2 uv = vec2(ray_value, u_colormap.texture_id);
    
    // Sample the colormap texture at the calculated UV coordinates and return the RGB color
    return texture(colormap, uv).rgb;
}
