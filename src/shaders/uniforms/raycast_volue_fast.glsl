#ifndef UNIFORMS_RAYCAST_VOLUME_FAST
#define UNIFORMS_RAYCAST_VOLUME_FAST

uniform sampler2D u_noisemap_data;
uniform sampler2D u_occupancy_data;
uniform vec3 u_occupancy_size;
uniform vec3 u_occupancy_block;
uniform float u_raycast_threshold;  
uniform float u_raycast_refinements;  
uniform float u_raycast_dither;

#endif