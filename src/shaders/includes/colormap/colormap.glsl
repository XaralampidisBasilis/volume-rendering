#include ../colormap/uniforms.glsl;
#include ../utils/ramp.glsl;

/**
 * Maps a float value to a color using a 2D colormap texture.
 *
 * @param u Input value to be mapped to a color
 *
 * @return vec3 The RGB color corresponding to the input value
 */
vec3 colormap(float u) 
{
    // Scale the input value 'u' using the provided limits
    u = ramp(u_colormap_u_lim[0], u_colormap_u_lim[1], u);
    
    // Interpolate the u-coordinate within the colormap texture range
    u = mix(u_colormap_u_range[0], u_colormap_u_range[1], u);

    // Return the sample from the colormap texture at the calculated coordinates
    return texture(u_colormap_data, vec2(u, u_colormap_v)).rgb;
}
