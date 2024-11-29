// precision
precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

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
    #include "./chunks/raycast/compute_raycast"
    #include "./chunks/colormap/compute_colormap"
    #include "./chunks/shading/compute_shading"

    fragColor = trace.shaded_color;
    #include "./chunks/compute_frag_depth"
    #include "./chunks/debug/compute_debug"
}
