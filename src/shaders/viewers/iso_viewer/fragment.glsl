// precision
precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

// varying
varying vec3 v_camera;
varying vec3 v_direction;
varying mat4 v_model_view_matrix;
varying mat4 v_projection_model_view_matrix;

// uniforms, parameters, utils
#include "./chunks/uniforms/uniforms"
#include "./chunks/parameters/parameters"
#include "./chunks/utils/utils"

// parameters
parameters_ray   ray;
parameters_trace trace;
parameters_trace prev_trace;
parameters_block block;
parameters_debug debug;

void main() 
{
    // set parameters
    #include "./chunks/parameters/set_parameters"
    #include "./chunks/raycasting/compute_raycasting"
    #include "./chunks/colormapping/compute_colormapping"
    #include "./chunks/lighting/compute_lighting"

    gl_FragColor = vec4(trace.shading, 1.0);
    #include "./chunks/compute_debug"
    #include "./chunks/compute_frag_depth"

    // include tone mapping and color space correction
    // #include <tonemapping_fragment>
    // #include <colorspace_fragment>
    
    // discard fragment if there is no intersection 
    if (!ray.intersected) discard;  
}
