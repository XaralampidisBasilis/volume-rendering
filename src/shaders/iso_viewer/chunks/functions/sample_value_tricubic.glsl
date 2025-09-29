/* Source:
   Beyond Trilinear Interpolation: Higher Quality for Free
   https://dl.acm.org/doi/10.1145/3306346.3323032
*/
#ifndef SAMPLE_VALUE_TRICUBIC
#define SAMPLE_VALUE_TRICUBIC

vec4 tricubic_bias(vec3 coords)
{
    vec3 r = fract(coords - 0.5);;
    vec3 bias = r * (r - 1.0) * 0.5;
    
    return vec4(bias, 1.0);
}

vec4 tricubic_features(in vec3 coords)
{
    // Normalize coordinates to texture space
    vec3 texture_coords = coords * u_volume.inv_dimensions;

    // Sample the precomputed augmented volume texture (fxx, fyy, fzz, f)
    return texture(u_textures.interpolation_map, texture_coords);
}

float sample_value_tricubic(in vec3 coords)
{
    // Sample the precomputed augmented volume texture (fxx, fyy, fzz, f)
    vec4 features = tricubic_features(coords);

    // Compute interpolation weights (quadratic bias terms + constant)
    vec4 bias = tricubic_bias(coords);

    // Compute corrected sample using dot product of coefficients and weights
    float value = dot(bias, features);

    return value;
}       

float sample_value_tricubic(in vec3 coords, out vec4 features)
{
    // Sample the precomputed augmented volume texture (fxx, fyy, fzz, f)
    features = tricubic_features(coords);

    // Compute interpolation weights (quadratic bias terms + constant)
    vec4 bias = tricubic_bias(coords);

    // Compute corrected sample using dot product of coefficients and weights
    float value = dot(bias, features);

    return value;
}    


#endif