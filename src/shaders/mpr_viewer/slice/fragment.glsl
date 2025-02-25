precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

in vec3 v_uvw;
in vec3 v_position;

out vec4 fragColor;

#include "./chunks/uniforms/uniforms"
#include "./chunks/utils"

void main() 
{
    bool is_outside = bool(outside_open_box(0.0, 1.0, v_uvw));
    if (is_outside)
    { 
        discard;
    }

    float intensity = texture(u_textures.intensity_map, v_uvw).r;
    float highlight = on(texture(u_textures.binary_map, v_uvw).r);
    
    fragColor = to_color(intensity); 
    fragColor.r += highlight * 0.4;
}