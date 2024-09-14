/* SOURCES
    1. MRIcroGL https://github.com/rordenlab/MRIcroWeb?tab=readme-ov-file
    2. Volume Rendering Example https://github.com/mrdoob/three.js/blob/master/examples/webgl_texture3d.html
*/

// precision
precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

// varying
varying vec3 v_camera;
varying vec3 v_direction;
varying mat4 v_projection_model_view_matrix;
varying mat4 v_model_view_matrix;

// uniforms, parameters, utils
#include "../../includes/uniforms/uniforms"
#include "../../includes/parameters/parameters"
#include "../../includes/utils/utils"

// func
#include "../../includes/raycasting/compute_raycasting"
#include "../../includes/colormapping/compute_colormapping"
#include "../../includes/lighting/compute_lighting"
#include "../../includes/debug/compute_debug"
#include "../../includes/compute_frag_depth"
    
void main() 
{
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
    ray.box_max = u_volume.size;

    ray.intersected = compute_raycasting(u_gradient, u_raycast, u_volume, u_occupancy, u_sampler, ray, trace, prev_trace); 
    trace.coords = floor(trace.position * u_volume.inv_spacing);
    trace.depth = trace.distance - ray.min_distance;
    trace.traversed = trace.depth - trace.skipped;
    // gl_FragColor = compute_debug(u_debug, u_gradient, u_raycast, u_volume, u_occupancy, ray, trace, debug); return;
   
    // compute color and lighting
    vec3 view_position = ray.origin;  
    vec3 light_position = v_camera + u_lighting.position * u_volume.size;
    trace.color = compute_colormapping(u_colormap, u_sampler.colormap, trace.value);
    trace.shading = compute_lighting(u_lighting, trace.color, trace.normal, trace.position, view_position, light_position);

    // set fragment color
    gl_FragColor = vec4(trace.shading, 1.0);
    gl_FragColor = compute_debug(u_debug, u_gradient, u_raycast, u_volume, u_occupancy, ray, trace, debug);

    // set fragment depth
    gl_FragDepth = compute_frag_depth(trace.position);

    // include tone mapping and color space correction
    // #include <tonemapping_fragment>
    // #include <colorspace_fragment>
    
    // discard fragment if there is no intersection or  ray does not intersect the box.
    if (!ray.intersected) discard;  
}
