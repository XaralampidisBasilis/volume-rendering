bool isosurface(in raycast_uniforms u_raycast, in float ray_intensity) 
{    
    return ray_intensity > u_raycast.threshold;
}
