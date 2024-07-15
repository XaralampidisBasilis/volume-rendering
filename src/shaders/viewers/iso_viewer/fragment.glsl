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
#include ../../includes/utils/intersect_box.glsl;
#include ../../includes/utils/intersect_box_max.glsl;
#include ../../includes/utils/reshape_coordinates.glsl;
#include ../../includes/utils/product.glsl;
#include ../../includes/utils/sum.glsl;
#include ../../includes/utils/ramp.glsl;
#include ../../includes/utils/posterize.glsl;

// functionality
#include ../../includes/raycast/raycast.glsl;
#include ../../includes/colormap/colormap.glsl;
#include ../../includes/gradient/gradient.glsl;
#include ../../includes/lighting/lighting.glsl;
#include ../../includes/raycast/depth.glsl;

void main() 
{
    // set out variables
    vec3 hit_position = vec3(0.0);
    float hit_intensity = 0.0;

    // normalize view direction vector
    vec3 ray_normal = normalize(v_direction);
    bool ray_hit = raycast(u_raycast, u_volume, u_occupancy, u_sampler, v_camera, ray_normal, hit_position, hit_intensity);
    
    return;

    // perform fast raycasting to get hit position and value
    if (ray_hit) {

        // compute the gradient normal vector at hit position
        vec3 normal_vector = gradient(u_gradient, u_volume, u_sampler, hit_position, hit_intensity);  // debug gl_FragColor = vec4((normal_vector * 0.5) + 0.5, 1.0);        
    
        // compute the max intensity color mapping
        vec3 intensity_color = colormap(u_colormap, u_sampler, hit_intensity); // debug gl_FragColor = vec4(intensity_color, 1.0);       

        // compute the lighting color
        vec3 hit_color = lighting(u_lighting, intensity_color, normal_vector, hit_position, v_camera, v_camera);

        // final color
        gl_FragColor = vec4(hit_color, 1.0);

        // final depth
        gl_FragDepth = depth(u_volume, hit_position);

        return;
        
    } else {
        discard;  // discard fragment if there is no hit
    }

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
