
// varying
out vec3 v_position;
out vec3 v_camera_position;
out vec3 v_camera_direction;
out vec3 v_ray_direction;
out mat4 v_model_view_matrix;
out mat4 v_projection_model_view_matrix;

void main() {				    

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // camera position in model coordinates
    vec4 camera_position = inverse(modelMatrix) * vec4(cameraPosition, 1.0);   
    vec4 camera_direction = inverse(modelViewMatrix) * vec4(0.0, 0.0, -1.0, 0.0);   

    // varying
    v_position = position; // vertex position in model coordinates
    v_camera_position = camera_position.xyz; // camera position in model coordinates
    v_camera_direction = camera_direction.xyz; // camera direction in model coordinates
    v_ray_direction = v_position - v_camera_position; // direction vector from camera to vertex in model coordinates
    v_model_view_matrix = modelViewMatrix;
    v_projection_model_view_matrix = projectionMatrix * modelViewMatrix;
}