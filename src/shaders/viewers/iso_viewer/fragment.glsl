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
    Ray ray = Ray();  
    Trace trace = Trace();
    Trace trace_prev = Trace();
    Occumap occumap = Occumap();
    Debug debug = Debug();

    #include "./chunks/raycasting/compute_raycasting"
    #include "./chunks/colormapping/compute_colormapping"
    #include "./chunks/shading/compute_shading"

    fragColor = vec4(trace.shading, 1.0);
    #include "./chunks/compute_frag_depth"
    #include "./chunks/debug/compute_debug"

    #if HAS_DEBUG_FULL == 0
        if (!ray.intersected) discard;  
    #endif
}
