varying mat4 v_matrix; // from vertex shader projectionMatrix * modelViewMatrix

float dithering(in sampler2D noise_data, in vec3 step, in vec2 range)
{
    vec3 depth = step * range.y;
    vec4 hash = v_matrix * vec4(depth, 0.0);
    hash *= 1000.0;

    return texture(noise_data, hash.xy).r;    
}