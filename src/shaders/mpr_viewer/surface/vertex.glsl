
out vec3 v_origin;
out vec3 v_direction;

void main() {				    

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // inverse matrices
    mat4 inv_model_matrix = inverse(modelMatrix);

    // camera position in model coordinates
    vec4 camera_position = inv_model_matrix * vec4(cameraPosition, 1.0);   

    // Camera varying
    v_origin = camera_position.xyz; // camera position in model coordinates

    // Ray varying
    v_direction = position - v_origin; // direction vector from camera to vertex in model coordinates
}