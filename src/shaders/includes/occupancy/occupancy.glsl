#include ../occupancy/mono_resolution.glsl;
#include ../occupancy/sub_resolution.glsl;
#include ../occupancy/multi_resolution.glsl;

bool occupancy(in occupancy_uniforms u_occupancy, in volume_uniforms u_volume, in sampler2D sampler_occupancy, in vec3 ray_position, in vec3 ray_step, out float skip_steps)
{
    bool occupied = true;
    
    switch (u_occupancy.method)
    {
        case 1: 
            occupied = mono_resolution(u_occupancy, u_volume, sampler_occupancy, ray_position, ray_step, skip_steps);
            break;
        case 2: 
            occupied = sub_resolution(u_occupancy, u_volume, sampler_occupancy, ray_position, ray_step, skip_steps);
            break;
        case 3:  
            occupied =  multi_resolution(u_occupancy, u_volume, sampler_occupancy, ray_position, ray_step, skip_steps);
            break;
    }

    return occupied;
}
