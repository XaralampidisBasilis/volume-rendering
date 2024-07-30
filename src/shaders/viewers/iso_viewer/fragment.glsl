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
#include "../../includes/uniforms/uniforms_sampler"
#include "../../includes/uniforms/uniforms_volume"
#include "../../includes/uniforms/uniforms_occupancy"
#include "../../includes/uniforms/uniforms_raycast"
#include "../../includes/uniforms/uniforms_gradient"
#include "../../includes/uniforms/uniforms_colormap"
#include "../../includes/uniforms/uniforms_lighting"

//param
#include "../../includes/parameters/parameters_ray"

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

// func
#include "../../includes/raycast/compute_raycast"
#include "../../includes/colormap/compute_color"
#include "../../includes/lighting/compute_lighting"

void main() 
{
    // initialize ray    
    ray.origin = v_camera;
    ray.direction = normalize(v_direction);   

    // perform raycasting
    bool intersection = compute_raycast(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray); 
    if (intersection) 
    {        
        // compute the max intensity color mapping
        vec3 color_sample = compute_color(u_colormap, u_sampler.colormap, ray.value); // debug gl_FragColor = vec4(intensity_color, 1.0);       

        // compute the lighting color
        vec3 color_lighting = compute_lighting(u_lighting, color_sample, ray.normal, ray.position, v_camera, v_camera);

        // final color
        gl_FragColor = vec4(color_lighting, 1.0);
        
        // final fragment depth
        gl_FragDepth = ray.depth;

        return;
        
    } 
    else discard;  // discard fragment if there is no hit
}
