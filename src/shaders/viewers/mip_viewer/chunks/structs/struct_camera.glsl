#ifndef STRUCT_CAMERA
#define STRUCT_CAMERA

struct Camera 
{
    vec3  position;          // position in model coordinates 
    vec3  texture_position;  // position in texture coordinates 
    vec3  direction;         // normalized direction in model coordinates 
    float near_distance;     // near clip plane distance in model coordinates 
    float far_distance;      // far clip plane distance in model coordinates 
};

Camera set_camera()
{
    Camera camera;
    camera.position         = v_camera_position;
    camera.texture_position = v_camera_position * u_volume.inv_size;
    camera.direction        = normalize(v_camera_direction);
    camera.near_distance    = v_camera_near_distance;
    camera.far_distance     = v_camera_far_distance;
    return camera;
}

#endif // STRUCT_CAMERA
