/**
 * Maps a float value to a color using a 2D colormap texture.
 *
 * @param u Input value to be mapped to a color
 * @return vec3 The RGB color corresponding to the input value
 */
vec3 colormap(in uniforms_colormap u_colormap, in uniforms_sampler u_sampler, in float intensity) 
{
    // Scale the input value 'u' using the provided limits
    intensity = ramp(u_colormap.u_lim.x, u_colormap.u_lim.y, intensity);
    
    // Interpolate the u-coordinate within the colormap texture range
    intensity = mix(u_colormap.u_range.x, u_colormap.u_range.y, intensity);

    // Return the sample from the colormap texture at the calculated coordinates
    vec2 uv = vec2(intensity, u_colormap.v);
    
    return sample_color_2d(u_sampler.colormap, uv).rgb;
}
