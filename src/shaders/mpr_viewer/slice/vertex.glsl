
out vec3 v_uvw; 
out vec3 v_position;

#include "./chunks/uniforms/uniforms"

void main() 
{
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // position in parent coordinates
    v_position = vec3(u_slice.transform * vec4(position, 1.0));

    // position in texture coordinates
    v_uvw = v_position * u_intensity_map.inv_size;
}