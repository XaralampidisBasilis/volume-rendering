
volume_uniforms u_volume = volume_uniforms(
    u_volume_size,
    u_volume_dimensions,
    u_volume_voxel
);

occupancy_uniforms u_occupancy = occupancy_uniforms(
   u_occupancy_dimensions,
   u_occupancy_block,
   u_occupancy_box_min,
   u_occupancy_box_max
);

raycast_uniforms u_raycast = raycast_uniforms(
    u_raycast_threshold,
    u_raycast_refinements,
    u_raycast_dither,
    u_raycast_resolution
);

gradient_uniforms u_gradient = gradient_uniforms( 
    u_gradient_method,
    u_gradient_resolution,
    u_gradient_neighbor
);


// function to set light uniforms struct
colormap_uniforms u_colormap = colormap_uniforms(
    u_colormap_u_range,
    u_colormap_u_lim,
    u_colormap_v
);

// function to set light uniforms struct
lighting_uniforms u_lighting = lighting_uniforms(
    u_lighting_attenuate,
    u_lighting_shininess,
    u_lighting_power,
    u_lighting_model,
    u_lighting_a_color,
    u_lighting_d_color,
    u_lighting_s_color,
    u_lighting_ka,
    u_lighting_kd,
    u_lighting_ks
);

