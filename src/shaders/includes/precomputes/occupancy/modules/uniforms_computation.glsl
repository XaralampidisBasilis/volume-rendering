#ifndef UNIFORMS_COMPUTATION
#define UNIFORMS_COMPUTATION

struct uniforms_computation 
{
    float threshold;
    sampler3D volume_data;
    ivec3 volume_dimensions;     
    ivec3 block_dimensions;
    ivec3 occupancy_dimensions;
    ivec2 computation_dimensions;  
};

uniform uniforms_computation u_computation;

#endif // UNIFORMS_COMPUTATION