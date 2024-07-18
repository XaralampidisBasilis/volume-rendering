/**
 * Maps a float value to a color using a 2D colormap texture.
 *
 * @param u Input value to be mapped to a color
 * @return vec3 The RGB color corresponding to the input value
 */
vec3 compute_color
(
    in uniforms_colormap u_colormap, 
    in uniforms_sampler u_sampler, 
    in float ray_sample
) 
{
    // Scale the input value 'u' using the provided limits
    ray_sample = rampstep(u_colormap.u_lim.x, u_colormap.u_lim.y, ray_sample);

    // Posterize the ray sample
    ray_sample = posterize(ray_sample, u_colormap.levels);
    
    // Interpolate the u-coordinate within the colormap texture range
    ray_sample = mix(u_colormap.u_range.x, u_colormap.u_range.y, ray_sample);

    // Return the sample from the colormap texture at the calculated coordinates
    vec2 uv = vec2(ray_sample, u_colormap.v);
    
    return sample_color_2d(u_sampler.colormap, uv).rgb;
}
