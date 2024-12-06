
out vec3 v_camera_position;
out vec3 v_camera_direction;
out vec3 v_camera_near_distance;
out vec3 v_camera_far_distance;
out vec3 v_ray_direction;
out mat4 v_model_view_matrix;
out mat4 v_projection_model_view_matrix;

void main() {				    

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // inverse matrices
    mat4 inv_model_matrix = inverse(modelMatrix);
    mat4 inv_model_view_matrix = inverse(modelViewMatrix);

    // camera position in model coordinates
    vec4 camera_position = inv_model_matrix * vec4(cameraPosition, 1.0);   
    vec4 camera_direction = inv_model_view_matrix * vec4(0.0, 0.0, -1.0, 0.0);

    // camera projection parameters
    float camera_depth_scale = projectionMatrix[2][2];
    float camera_depth_offset = projectionMatrix[2][3];

    // Camera varying
    v_camera_position = camera_position.xyz; // camera position in model coordinates
    v_camera_direction = camera_direction.xyz; // camera direction in model coordinates
    v_camera_near_distance = camera_depth_offset / (2.0 * camera_depth_scale + 2.0); // camera near clip plane distance in view coordinates
    v_camera_far_distance = camera_depth_offset / (2.0 * camera_depth_scale - 2.0); // camera far clip plane distance in view coordinates
    v_camera_near_distance = length(inv_model_matrix * vec4(0.0, 0.0, -v_camera_near_distance, 0.0)); // camera near clip plane distance in model coordinates
    v_camera_far_distance = length(inv_model_matrix * vec4(0.0, 0.0, -v_camera_far_distance, 0.0)); // camera far clip plane distance in model coordinates

    // Ray varying
    v_ray_direction = position - v_camera_position; // direction vector from camera to vertex in model coordinates

    // Matrix varying
    v_model_view_matrix = modelViewMatrix;
    v_projection_model_view_matrix = projectionMatrix * modelViewMatrix;

}