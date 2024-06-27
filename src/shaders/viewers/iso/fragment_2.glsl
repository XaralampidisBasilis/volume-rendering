/* SOURCES
    1. MRIcroGL https://github.com/rordenlab/MRIcroWeb?tab=readme-ov-file
    2. Volume Rendering Example https:///github.com/mrdoob/three.js/blob/master/examples/webgl_texture3d.html
*/
precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data;
uniform vec3 u_volume_voxel;
uniform float u_raycast_resolution;
uniform vec3 u_occupancy_box_min;
uniform vec3 u_occupancy_box_max;

varying vec3 v_position;
varying vec3 v_camera;
varying vec3 v_direction;

#include ../../utils/intersect_box.glsl;
#include ../../includes/gradient_methods.glsl;
#include ../../includes/lighting_phong.glsl;
#include ../../includes/color_mapping.glsl;
#include ../../includes/raycast_volume_fast.glsl;
#include ../../includes/ray_step.glsl;

void main() 
{
    // normalize view direction vector
    vec3 direction = normalize(v_direction);

    vec2 range = intersect_box(u_occupancy_box_min, u_occupancy_box_max, v_camera, direction);
    range = max(range, 0.0); // Ensure the range is non-negative

    // calculate ray step vector
    vec3 step = ray_step_2(direction, range, u_volume_voxel, u_raycast_resolution);       

    // intersect volume box with ray and compute the range
    range = intersect_box(u_occupancy_box_min, u_occupancy_box_max, v_camera, step);
    range = max(range, 0.0); // Ensure the range is non-negative

    // discard fragments if the ray does not intersect the box
    if (range.x > range.y) discard; 

    // perform fast raycasting to get hit position and value
    float value = 0.0;
    vec3 position = v_camera;
    bool hit = raycast_volume_fast(u_volume_data, v_camera, step, range, position, value);

    if (hit) {

        // compute the gradient normal vectir at hit position
        float value_near = 0.0;
        vec3 normal_vector = gradient_methods(u_volume_data, position, u_volume_voxel, value_near);

        // determine maximum value for color mapping
        float value_max = max(value, value_near);    
        vec3 color = color_mapping(value_max);        

        // apply phong illuminaton model
        vec3 view_vector = v_camera - v_position;
        vec3 light_vector = view_vector + vec3(0.0, 0.2, 0.0);
        vec3 color_phong = lighting_phong(color, normal_vector, view_vector, light_vector);

        gl_FragColor = vec4(color_phong, 1.0);
        return;
        
    }
    else 
        discard;  // discard fragment if there is no hit

    // include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
