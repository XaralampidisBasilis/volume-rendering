// COMPUTE DEBUG 

// depth
vec4 debug_frag_depth = to_color(frag.depth);

// position
vec4 debug_frag_position = to_color(frag.position.xyz);

// camera angle
vec4 debug_frag_camera_angle = to_color(acos(frag.camera_angle) / PI);

// mapped intensity
vec4 debug_frag_mapped_intensity = to_color(frag.mapped_intensity);

// mapped color
vec4 debug_frag_mapped_color = to_color(frag.mapped_color.rgb);

// PRINT DEBUG

switch (u_debugging.option - debug_slot_frag)
{
    case 1: fragColor = debug_frag_depth;            break;
    case 2: fragColor = debug_frag_position;         break;
    case 3: fragColor = debug_frag_camera_angle;     break;
    case 4: fragColor = debug_frag_mapped_intensity; break;
    case 5: fragColor = debug_frag_mapped_color;     break;

}   