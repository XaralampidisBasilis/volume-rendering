#ifndef STRUCT_CAMERA
#define STRUCT_CAMERA

struct Camera 
{
    vec3  position; // position in texture coordinates 
};

Camera set_camera()
{
    Camera camera;
    camera.position = v_origin;
    return camera;
}

#endif // STRUCT_CAMERA
