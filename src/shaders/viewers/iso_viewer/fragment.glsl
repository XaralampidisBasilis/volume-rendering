// precision
precision lowp sampler3D;
precision lowp sampler2D;
precision lowp float;
precision lowp int;

// varying
in vec3 v_camera_position;
in vec3 v_camera_direction;
in vec3 v_ray_direction;
in mat4 v_model_view_matrix;
in mat4 v_projection_model_view_matrix;

out vec4 fragColor;

// uniforms, defines, structs, utils
#include "./chunks/uniforms/uniforms"
#include "./chunks/structs/structs"
#include "./chunks/utils/utils"
#include "./chunks/consts/consts"

void main() 
{
    #include "./chunks/structs/set_structs"
    #include "./chunks/raycasting/compute_raycasting"
    #include "./chunks/colormapping/compute_colormapping"
    #include "./chunks/shading/compute_shading"

    fragColor = trace.shaded_color;
    #include "./chunks/compute_frag_depth"
    #include "./chunks/debug/compute_debug"
}
