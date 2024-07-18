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
varying mat4 v_projection_model_view_matrix; // from vertex shader projectionMatrix * modelMatrix * viewMatrix

// uniforms
#include ./uniforms/u_sampler.glsl;
#include ./uniforms/u_volume.glsl;
#include ./uniforms/u_occupancy.glsl;
#include ./uniforms/u_raycast.glsl;
#include ./uniforms/u_gradient.glsl;
#include ./uniforms/u_colormap.glsl;
#include ./uniforms/u_lighting.glsl;

// utils
#include ../../includes/utils/sample_color.glsl;
#include ../../includes/utils/sample_intensity.glsl;
#include ../../includes/utils/inside_texture.glsl;
#include ../../includes/utils/intersect_box.glsl;
#include ../../includes/utils/intersect_box_max.glsl;
#include ../../includes/utils/intersect_box_min.glsl;
#include ../../includes/utils/reshape_coordinates.glsl;
#include ../../includes/utils/product.glsl;
#include ../../includes/utils/sum.glsl;
#include ../../includes/utils/rampstep.glsl;
#include ../../includes/utils/posterize.glsl;

// functionality
#include ../../includes/raycast/compute_raycast.glsl;
#include ../../includes/colormap/compute_color.glsl;
#include ../../includes/gradient/compute_gradient.glsl;
#include ../../includes/lighting/compute_lighting.glsl;

void main() 
{
    // set ray variables
    vec3 ray_normal = normalize(v_direction);   
    vec3 hit_position = vec3(0.0);
    float hit_sample = 0.0;
    float hit_depth = 0.0;
    float hit_alpha = 1.0;

    // perform raycasting
    bool intersected = compute_raycast(u_raycast, u_volume, u_occupancy, u_sampler, v_camera, ray_normal, hit_position, hit_sample, hit_depth); 
    if (intersected) 
    {        
        // compute the gradient normal vector at hit position
        vec3 gradient_vector = compute_gradient(u_gradient, u_volume, u_sampler, hit_position, hit_sample, hit_alpha);  // debug gl_FragColor = vec4((normal_vector * 0.5) + 0.5, 1.0);        
    
        // compute the max intensity color mapping
        vec3 color_sample = compute_color(u_colormap, u_sampler, hit_sample); // debug gl_FragColor = vec4(intensity_color, 1.0);       

        // compute the lighting color
        vec3 color_lighting = compute_lighting(u_lighting, color_sample, gradient_vector, hit_position, v_camera, v_camera);

        // final color
        hit_alpha = float(hit_alpha > u_gradient.threshold); // if occupancy gets zero then there is nothing behind to plot
        gl_FragColor = vec4(color_lighting, hit_alpha);
        
        // final fragment depth
        gl_FragDepth = hit_depth;

        return;
        
    } 
    else discard;  // discard fragment if there is no hit

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
