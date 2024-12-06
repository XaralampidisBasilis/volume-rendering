#ifndef UNIFORMS_CAMERA
#define UNIFORMS_CAMERA

struct Camera 
{
    vec3  position;
    vec3  direction;
    float near_distance;
    float far_distance;

};

uniform Camera u_camera;

#endif // UNIFORMS_CAMERA