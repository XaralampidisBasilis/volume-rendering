// precision
precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

// varying
in vec3 v_camera;
in vec3 v_direction;
in mat4 v_model_view_matrix;
in mat4 v_projection_model_view_matrix;

out vec4 fragColor;

// uniforms, parameters, utils
#include "./chunks/uniforms/uniforms"
#include "./chunks/defines/defines"
#include "./chunks/parameters/parameters"
#include "./chunks/utils/utils"

void main() 
{
    #include "./chunks/parameters/set_parameters"
    #include "./chunks/raycasting/compute_raycasting"
    #include "./chunks/colormapping/compute_colormapping"
    #include "./chunks/shading/compute_shading"

    fragColor = vec4(trace.shading, 1.0);
    #include "./chunks/compute_frag_depth"

    if (!ray.intersected) discard;  
}
