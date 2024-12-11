#ifndef UNIFORMS_COLORMAP
#define UNIFORMS_COLORMAP

struct Colormap 
{
    int  levels;      
    int  name;        
    vec2 thresholds;  
    vec2 start_coords;
    vec2 end_coords;  
};

uniform Colormap u_colormap;

#endif