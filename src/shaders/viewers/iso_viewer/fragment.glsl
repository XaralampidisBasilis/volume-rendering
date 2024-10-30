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

// uniforms, defines, structs, utils
#include "./chunks/uniforms/uniforms"
#include "./chunks/defines/defines"
#include "./chunks/structs/structs"
#include "./chunks/utils/utils"

void main() 
{
    Ray ray = set_ray();  
    Trace trace = set_trace();
    Trace trace_prev = set_trace();
    Occumap occumap = set_occumap();
    Debug debug = set_debug();

    #include "./chunks/raycasting/compute_raycasting"
    #include "./chunks/colormapping/compute_colormapping"
    #include "./chunks/shading/compute_shading"

    fragColor = trace.shaded_color;
    #include "./chunks/compute_frag_depth"
    #include "./chunks/debug/compute_debug"

    #if RAY_DISCARDING_DISABLED == 0
        if (!ray.intersected) discard;  
    #endif
}
