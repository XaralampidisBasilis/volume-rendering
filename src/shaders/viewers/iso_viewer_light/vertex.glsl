
// varying
out vec3 v_position;
out vec3 v_camera;
out vec3 v_direction;
out mat4 v_model_view_matrix;
out mat4 v_projection_model_view_matrix;

void main() {				    

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // camera position in model coordinates
    vec4 camera = inverse(modelMatrix) * vec4(cameraPosition, 1.0);   

    // varying
    v_position = position; // vertex position in model coordinates
    v_camera = camera.xyz; // camera position in model coordinates
    v_direction = v_position - v_camera; // direction vector from camera to vertex in model coordinates
    v_model_view_matrix = modelViewMatrix;
    v_projection_model_view_matrix = projectionMatrix * modelViewMatrix;
}