#ifndef UNIFORM_COLORMAP
#define UNIFORM_COLORMAP

// struct to hold colormap uniforms
struct Colormap 
{
    int name;
    float texture_row;     
    vec2 texture_columns;
    float low;  
    float high;  
    float levels;
};

#endif
