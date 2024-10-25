#ifndef UNIFORM_COLORMAP
#define UNIFORM_COLORMAP

struct Colormap 
{
    int  levels;      
    int  name;        
    vec2 thresholds;  
    vec2 start_coords;
    vec2 end_coords;  
};

#endif
