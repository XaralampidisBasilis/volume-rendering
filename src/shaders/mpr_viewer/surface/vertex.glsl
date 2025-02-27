
out vec3 v_origin;
out vec3 v_direction;
out mat4 v_clip_space_matrix;

void main() {				    

    // matrices
    mat4 inv_model_matrix = inverse(modelMatrix);
    v_clip_space_matrix = projectionMatrix * modelViewMatrix;

    // camera position in model coordinates
    vec4 camera_position = inv_model_matrix * vec4(cameraPosition, 1.0);   

    // camera varying
    v_origin = camera_position.xyz; // camera position in model coordinates

    // ray varying
    v_direction = position - v_origin; // direction vector from camera to vertex in model coordinates

    // vertex position
    gl_Position = v_clip_space_matrix * vec4(position, 1.0);
}