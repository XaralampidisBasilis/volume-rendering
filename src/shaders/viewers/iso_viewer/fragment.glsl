precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

in vec3 v_camera_position;
in vec3 v_camera_direction;
in float v_camera_near_distance;
in float v_camera_far_distance;
in vec3 v_ray_direction;
in mat4 v_model_view_matrix;
in mat4 v_projection_model_view_matrix;

out vec4 fragColor;

#include "./chunks/uniforms/uniforms"
#include "./chunks/structs/structs"
#include "./chunks/utils/utils"
#include "./chunks/consts/consts"

void main() 
{
    #include "./chunks/structs/set_structs"
    #include "./chunks/raycast/compute_raycast"
    #include "./chunks/march/compute_march"
    #include "./chunks/shade/compute_shade"
    // #include "./chunks/debug/compute_debug"
}
