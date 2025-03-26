
out vec3 v_uvw; 
out vec3 v_position;

#include "./chunks/uniforms/uniforms"

void main() 
{
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // position in parent coords [0, size]
    v_position = vec3(u_slice.matrix * vec4(position, 1.0));

    // position in texture coords [0, 1]
    v_uvw = v_position * u_volume.inv_size;
}