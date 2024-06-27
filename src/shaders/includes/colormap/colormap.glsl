#include ../utils/ramp.glsl;
#include ../utils/sample_colormap.glsl;

/**
 * Maps a float value to a color using a 2D colormap texture.
 *
 * @param u Input value to be mapped to a color
 *
 * @return vec3 The RGB color corresponding to the input value
 */
vec3 colormap(colormap_uniforms u_colormap, float intensity) 
{
    // Scale the input value 'u' using the provided limits
    intensity = ramp(u_colormap.u_lim.x, u_colormap.u_lim.y, intensity);
    
    // Interpolate the u-coordinate within the colormap texture range
    intensity = mix(u_colormap.u_range.x, u_colormap.u_range.y, intensity);

    // Return the sample from the colormap texture at the calculated coordinates
    vec2 uv = vec2(intensity, u_colormap.v);
    
    return sample_colormap(u_colormap.data, uv);
}
