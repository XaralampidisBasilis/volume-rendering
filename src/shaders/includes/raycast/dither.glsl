varying mat4 v_matrix; // from vertex shader projectionMatrix * modelViewMatrix

float dither(in raycast_uniforms uniforms, in vec3 ray_step, in vec2 step_bounds)
{
    vec3 depth = ray_step * step_bounds.y;
    vec4 hash = v_matrix * vec4(depth, 0.0);
    hash *= 1000.0;

    return texture(uniforms.noisemap, hash.xy).r * uniforms.dither;    
}