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
    bool is_inside = bool(inside_closed_box(0.0, 1.0, v_uvw));
    if (is_inside)
    { 
        float intensity = texture(u_textures.intensity_map, v_uvw).r;
        fragColor = to_color(intensity); 

        ivec3 coords = ivec3(v_position * u_intensity_map.inv_spacing);
        float highlight = texelFetch(u_textures.binary_map, coords, 0).r;
        fragColor.r += on(highlight) * 0.3;    
    }
    else 
    {
        discard;
    }

}