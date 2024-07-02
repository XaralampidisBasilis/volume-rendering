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
#include ../../includes/uniforms/u_sampler.glsl;
#include ../../includes/uniforms/u_volume.glsl;
#include ../../includes/uniforms/u_occupancy.glsl;
#include ../../includes/uniforms/u_raycast.glsl;
#include ../../includes/uniforms/u_gradient.glsl;
#include ../../includes/uniforms/u_colormap.glsl;
#include ../../includes/uniforms/u_lighting.glsl;

// utils
#include ../../includes/utils/sample_color.glsl;
#include ../../includes/utils/sample_intensity.glsl;
#include ../../includes/utils/intersect_box.glsl;
#include ../../includes/utils/intersect_box_max.glsl;
#include ../../includes/utils/reshape_coordinates.glsl;
#include ../../includes/utils/ramp.glsl;

// functionality
#include ../../includes/colormap/colormap.glsl;
#include ../../includes/gradient/gradient.glsl;
#include ../../includes/lighting/lighting.glsl;
#include ../../includes/raycast/raycast_1.glsl;

void main() 
{
    // set uniform variables
    #include ../../includes/uniforms/uniforms.glsl;    

    // set out variables
    vec3 hit_position = vec3(0.0);
    float hit_intensity = 0.0;

    // normalize view direction vector
    vec3 ray_normal = normalize(v_direction);
    bool ray_hit = raycast_1(u_raycast, u_volume, u_occupancy, u_sampler_volume, u_sampler_occupancy, v_camera, ray_normal, hit_position, hit_intensity);
    
    // if (ray_hit) return;
    // discard;

    // perform fast raycasting to get hit position and value
    if (ray_hit) {

        // compute the gradient normal vector at hit position
        vec3 normal_vector = gradient(u_gradient, u_volume, u_sampler_volume, hit_position, hit_intensity);  // debug gl_FragColor = vec4((normal_vector * 0.5) + 0.5, 1.0);        
    
        // compute the max intensity color mapping
        vec3 intensity_color = colormap(u_colormap, u_sampler_colormap, hit_intensity); // debug gl_FragColor = vec4(intensity_color, 1.0);       

        // compute the lighting color
        vec3 hit_color = lighting(u_lighting, intensity_color, normal_vector, hit_position, v_camera, v_camera);

        // final color
        gl_FragColor = vec4(hit_color, 1.0);
        return;
        
    } else {
        
        discard;  // discard fragment if there is no hit
    }

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
