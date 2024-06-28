uniform vec3 u_volume_size;

varying vec3 v_position;
varying vec3 v_camera;
varying vec3 v_direction;
varying mat4 v_projection_model_view_matrix;

void main() {				    

    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);

    // camera position in model coordinates
    vec4 camera = inverse(modelMatrix) * vec4(cameraPosition, 1.0);   

    // Varying
    v_position = position / u_volume_size; // vertex position in model texel coordinates
    v_camera = camera.xyz / u_volume_size; // camera position in model texel coordinates
    v_direction = v_position - v_camera; // direction vector from camera to vertex in model texel coordinates
    v_projection_model_view_matrix = projectionMatrix * modelViewMatrix;
}