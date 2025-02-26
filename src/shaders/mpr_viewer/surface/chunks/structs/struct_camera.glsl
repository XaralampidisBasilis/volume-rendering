#ifndef STRUCT_CAMERA
#define STRUCT_CAMERA

struct Camera 
{
    vec3  position;       // position in model coordinates 
    vec3  uvw;            // position in texture coordinates 
};

Camera set_camera()
{
    Camera camera;
    camera.position = v_origin;
    camera.uvw = camera.position * u_intensity_map.inv_size;
    return camera;
}

#endif // STRUCT_CAMERA
