precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

in vec3  v_origin;
in vec3  v_direction;

out vec4 fragColor;

#include "./chunks/utils/utils"
#include "./chunks/uniforms/uniforms"
#include "./chunks/funs/funs"
#include "./chunks/structs/structs"
#include "./chunks/consts/consts"

void main() 
{
    #include "./chunks/structs/set_structs"
    #include "./chunks/raycast/compute_raycast"
    #include "./chunks/march/compute_march"
    #include "./chunks/shade/compute_shade"

    #if DEBUG_ENABLED == 1
    #include "./chunks/debug/compute_debug"
    #endif
}
