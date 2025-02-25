#ifndef UNIFORMS_COLOR_MAP
#define UNIFORMS_COLOR_MAP

struct ColorMap 
{
    int  levels;      
    int  name;        
    vec2 thresholds;  
    vec2 start_coords;
    vec2 end_coords;  
};

uniform ColorMap u_color_map;

#endif
