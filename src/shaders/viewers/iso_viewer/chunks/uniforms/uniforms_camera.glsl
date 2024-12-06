#ifndef UNIFORMS_CAMERA
#define UNIFORMS_CAMERA

struct Camera 
{
    float near_plane;
    float far_plane;
    vec3 position;
};

uniform Camera u_camera;

#endif // UNIFORMS_CAMERA