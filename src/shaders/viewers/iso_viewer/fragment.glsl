// precision
precision lowp sampler3D;
precision lowp sampler2D;
precision lowp float;
precision lowp int;

// varying
varying vec3 v_camera;
varying vec3 v_direction;
varying mat4 v_model_view_matrix;
varying mat4 v_projection_model_view_matrix;

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
    #include "./chunks/lighting/compute_lighting"

    gl_FragColor = vec4(trace.shading, 1.0);

    #include "./chunks/compute_frag_depth"
    #include "./chunks/debug/compute_debug"

    if (!ray.intersected) discard;  
}
