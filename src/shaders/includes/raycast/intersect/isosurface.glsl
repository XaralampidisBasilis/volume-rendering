

bool isosurface(in raycast_uniforms u_raycast, in vec3 ray_step, out vec3 ray_position, out float ray_intensity) 
{    
    // check if the sampled intensity exceeds the isosurface threshold
    if (ray_intensity > u_raycast.threshold) {

        // refine the hit position and intensity
        refine(u_raycast, sampler_volume, ray_step, ray_position, ray_intensity);
        return true; // intersection found
    }

    return false; // intersection not found
}
