#ifndef UNIFORMS_RAYCAST_VOLUME
#define UNIFORMS_RAYCAST_VOLUME

uniform float u_raycast_threshold;  // Threshold value to determine if the ray has hit an object
uniform float u_raycast_refinements;  // Number of refinements for raycasting precision
uniform float u_raycast_dithering;
uniform sampler2D u_noisemap_data;

#endif