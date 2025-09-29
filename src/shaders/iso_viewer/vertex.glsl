
out vec3 v_position;
out vec3 v_camera_position;
out vec3 v_camera_direction;
out vec3 v_ray_direction;

uniform mat4 uCustomModelMatrix;

void main() 
{	
    const vec3 cameraDirection = vec3(0.0, 0.0, -1.0);
  
    // vertex position varying
    v_position = vec3(uCustomModelMatrix * vec4(position, 1.0));

    // Camera varying
    v_camera_position = vec3(uCustomModelMatrix * inverse(modelMatrix) * vec4(cameraPosition, 1.0));   

    // camera direction
    v_camera_direction = vec3(uCustomModelMatrix * inverse(modelViewMatrix) * vec4(cameraDirection, 0.0));

    // Ray varying
    v_ray_direction = v_position - v_camera_position; // direction vector from camera to vertex in grid coordinates

    // Vertex position in physical space
    gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
}