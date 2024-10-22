#ifndef PARAMETERS_OCCUMAP
#define PARAMETERS_OCCUMAP

// struct to hold gradient uniforms
struct parameters_occumap
{
    int max_skips;
    int lod;
    float lod_scale;
    ivec3 dimensions;
    ivec3 offset;
    vec3 spacing;
};

void set(out parameters_occumap occumap)
{
    occumap.max_skips   = 0;
    occumap.lod         = 0;
    occumap.lod_scale   = 0.0;
    occumap.dimensions  = ivec3(0);
    occumap.offset      = ivec3(0);
    occumap.spacing     = vec3(0.0);
}

#endif