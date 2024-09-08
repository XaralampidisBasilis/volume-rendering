/* SOURCES
    1. MRIcroGL https://github.com/rordenlab/MRIcroWeb?tab=readme-ov-file
    2. Volume Rendering Example https://github.com/mrdoob/three.js/blob/master/examples/webgl_texture3d.html
*/

// precision
precision lowp sampler3D;
precision lowp sampler2D;
precision lowp float;

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
#include "../../includes/uniforms/uniforms_debug"

//param
#include "../../includes/parameters/parameters_ray"
#include "../../includes/parameters/parameters_trace"
#include "../../includes/parameters/parameters_debug"

// utils
#include "../../includes/utils/inside_texture"
#include "../../includes/utils/intersect_box"
#include "../../includes/utils/intersect_box_max"
#include "../../includes/utils/intersect_box_min"
#include "../../includes/utils/reshape_coordinates"
#include "../../includes/utils/prod"
#include "../../includes/utils/sum"
#include "../../includes/utils/rampstep"
#include "../../includes/utils/posterize"

// func
#include "../../includes/raycasting/compute_raycasting"
#include "../../includes/colormapping/compute_colormapping"
#include "../../includes/lighting/compute_lighting"
#include "../../includes/compute_frag_depth"
#include "../../includes/compute_debug"

void main() 
{
    // set parameters
    parameters_ray ray;
    parameters_trace trace;
    parameters_trace prev_trace;
    parameters_debug debug;

    // initialize parameters
    set_ray(ray);
    set_trace(trace);
    set_trace(prev_trace);
    set_debug(debug);
   
    // compute raycast
    ray.origin = v_camera;
    ray.direction = normalize(v_direction);

    bool hit = compute_raycasting(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace, prev_trace); 
    // gl_FragColor = compute_debug(u_debug, u_gradient, u_raycast, u_volume, u_occupancy, ray, trace); return;

    // hit detected
    if (hit) 
    {                
        vec3 view_position = ray.origin;  
        vec3 light_position = v_camera + u_lighting.position * u_volume.size;

        // compute color and lighting
        trace.color = compute_colormapping(u_colormap, u_sampler.colormap, trace.value);
        trace.lighting = compute_lighting(u_lighting, trace.color, trace.normal, trace.position, view_position, light_position);

        // set fragment depth
        gl_FragDepth = compute_frag_depth(trace.position);

        // set fragment color
        gl_FragColor = vec4(trace.lighting, 1.0);
       
        // debug
        gl_FragColor = compute_debug(u_debug, u_gradient, u_raycast, u_volume, u_occupancy, ray, trace);

        return;
    }   
    // discard fragment if there is no intersection
    else discard;  
}
