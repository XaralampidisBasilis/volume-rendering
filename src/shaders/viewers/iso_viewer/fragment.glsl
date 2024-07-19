/* SOURCES
    1. MRIcroGL https://github.com/rordenlab/MRIcroWeb?tab=readme-ov-file
    2. Volume Rendering Example https://github.com/mrdoob/three.js/blob/master/examples/webgl_texture3d.html
*/

// precision
precision highp sampler3D;
precision highp sampler2D;
precision highp float;

// varying
varying vec3 v_camera;
varying vec3 v_direction;
varying mat4 v_projection_model_view_matrix;
varying mat4 v_model_view_matrix;

// uniforms
#include "./uniforms/uniforms_sampler"
#include "./uniforms/uniforms_volume"
#include "./uniforms/uniforms_occupancy"
#include "./uniforms/uniforms_raycast"
#include "./uniforms/uniforms_gradient"
#include "./uniforms/uniforms_colormap"
#include "./uniforms/uniforms_lighting"

// utils
#include "../../includes/utils/sample_color"
#include "../../includes/utils/sample_intensity"
#include "../../includes/utils/inside_texture"
#include "../../includes/utils/intersect_box"
#include "../../includes/utils/intersect_box_max"
#include "../../includes/utils/intersect_box_min"
#include "../../includes/utils/reshape_coordinates"
#include "../../includes/utils/product"
#include "../../includes/utils/sum"
#include "../../includes/utils/rampstep"
#include "../../includes/utils/posterize"

// functionality
#include "../../includes/gradient/compute_gradient"
#include "../../includes/raycast/compute_raycast"
#include "../../includes/colormap/compute_color"
#include "../../includes/lighting/compute_lighting"

void main() 
{
    // set ray variables
    vec3 ray_normal = normalize(v_direction);   
    vec3 hit_position = vec3(0.0);
    vec3 hit_normal = vec3(0.0);
    float hit_sample = 0.0;
    float hit_depth = 0.0;

    // perform raycasting
    bool intersected = compute_raycast(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, v_camera, ray_normal, hit_position, hit_normal, hit_sample, hit_depth); 
    if (intersected) 
    {        
        // compute the max intensity color mapping
        vec3 color_sample = compute_color(u_colormap, u_sampler, hit_sample); // debug gl_FragColor = vec4(intensity_color, 1.0);       

        // compute the lighting color
        vec3 color_lighting = compute_lighting(u_lighting, color_sample, hit_normal, hit_position, v_camera, v_camera);

        // final color
        gl_FragColor = vec4(color_lighting, 1.0);
        
        // final fragment depth
        gl_FragDepth = hit_depth;

        return;
        
    } 
    else discard;  // discard fragment if there is no hit

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
