// COMPUTE DEBUG 

// depth
debug.frag_depth = vec4(vec3(frag.depth), 1.0);

// position
debug.frag_position = vec4(frag.position.xyz, 1.0);

// normal vector
vec3 debug_frag_normal_vector = frag.normal_vector * 0.5 + 0.5;
debug.frag_normal_vector = vec4(debug_frag_normal_vector, 1.0);

// view vector
vec3 debug_frag_view_vector = frag.view_vector * 0.5 + 0.5;
debug.frag_view_vector = vec4(debug_frag_view_vector, 1.0);

// light vector
vec3 debug_frag_light_vector = frag.light_vector * 0.5 + 0.5;
debug.frag_light_vector = vec4(debug_frag_light_vector, 1.0);

// halfway vector
vec3 debug_frag_halfway_vector = frag.halfway_vector * 0.5 + 0.5;
debug.frag_halfway_vector = vec4(debug_frag_halfway_vector, 1.0);

// view angle
float debug_frag_view_angle = map(-1.0, 1.0, frag.view_angle);
debug.frag_view_angle = vec4(vec3(debug_frag_view_angle), 1.0);

// light angle
float debug_frag_light_angle = map(-1.0, 1.0, frag.light_angle);
debug.frag_light_angle = vec4(vec3(debug_frag_light_angle), 1.0);

// halfway angle
float debug_frag_halfway_angle = map(-1.0, 1.0, frag.halfway_angle);
debug.frag_halfway_angle = vec4(vec3(debug_frag_halfway_angle), 1.0);

// camera angle
float debug_frag_camera_angle = acos(frag.camera_angle) / PI;
debug.frag_camera_angle = vec4(vec3(debug_frag_camera_angle), 1.0);

// mapped intensity
debug.frag_mapped_intensity = vec4(vec3(frag.mapped_intensity), 1.0);

// mapped color
debug.frag_mapped_color = vec4(frag.mapped_color.rgb, 1.0);

// ambient color
debug.frag_ambient_color = vec4(frag.ambient_color.rgb, 1.0);

// diffuse color
debug.frag_diffuse_color = vec4(frag.diffuse_color.rgb, 1.0);

// specular color
debug.frag_specular_color = vec4(frag.specular_color.rgb, 1.0);

// shaded color
debug.frag_shaded_color = vec4(frag.shaded_color.rgb, 1.0);

// shaded luminance
float debug_frag_shaded_luminance = dot(frag.shaded_color.rgb, vec3(0.2126, 0.7152, 0.0722));
debug.frag_shaded_luminance = vec4(vec3(debug_frag_shaded_luminance), 1.0);


// PRINT DEBUG

switch (u_debugging.option - debug.slot_frag)
{
    case  1: fragColor = debug.frag_depth;              break; 
    case  2: fragColor = debug.frag_position;           break; 
    case  3: fragColor = debug.frag_normal_vector;      break; 
    case  4: fragColor = debug.frag_view_vector;        break; 
    case  5: fragColor = debug.frag_light_vector;       break; 
    case  6: fragColor = debug.frag_halfway_vector;     break; 
    case  7: fragColor = debug.frag_view_angle;         break; 
    case  8: fragColor = debug.frag_light_angle;        break; 
    case  9: fragColor = debug.frag_halfway_angle;      break; 
    case 10: fragColor = debug.frag_camera_angle;       break; 
    case 11: fragColor = debug.frag_mapped_intensity;   break; 
    case 12: fragColor = debug.frag_mapped_color;       break; 
    case 13: fragColor = debug.frag_ambient_color;      break; 
    case 14: fragColor = debug.frag_diffuse_color;      break; 
    case 15: fragColor = debug.frag_specular_color;     break; 
    case 16: fragColor = debug.frag_shaded_color;       break; 
    case 17: fragColor = debug.frag_shaded_luminance;   break; 
}   