
in vec3 v_origin;
in vec3 v_direction;
in mat4 v_clip_space_matrix;

out vec4 fragColor;

#include "./chunks/utils"
#include "./chunks/uniforms/uniforms"
#include "./chunks/structs/structs"

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
