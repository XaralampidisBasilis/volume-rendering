
out vec3 v_position;
out vec3 v_origin;
out vec3 v_direction;
out mat4 v_clip_space_matrix;

#include "./chunks/uniforms/uniforms"

void main() {				    

    // matrices
    v_clip_space_matrix = projectionMatrix * modelViewMatrix;

    // camera position in model coordinates
    vec4 camera_position = inverse(modelMatrix) * vec4(cameraPosition, 1.0);   

    // camera position varying
    v_origin = camera_position.xyz * u_volume.dimensions; // camera position in grid coordinates

    // vertex position varying
    v_position = position * u_volume.dimensions; // vertex position in grid coordinates

    // ray direction varying
    v_direction = v_position - v_origin; // direction vector from camera to vertex in grid coordinates

    // vertex position
    gl_Position = v_clip_space_matrix * vec4(position, 1.0);
}