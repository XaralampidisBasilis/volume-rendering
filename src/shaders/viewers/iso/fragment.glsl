/* SOURCES
    1. MRIcroGL https://github.com/rordenlab/MRIcroWeb?tab=readme-ov-file
    2. Volume Rendering Example https:///github.com/mrdoob/three.js/blob/master/examples/webgl_texture3d.html
*/
precision highp float;
precision highp sampler3D; // highp, mediump, lowp

uniform sampler3D u_volume_data;
uniform vec3 u_volume_voxel;
uniform float u_raycast_resolution;

varying vec3 v_position;
varying vec3 v_camera;
varying vec3 v_direction;

#include ../../utils/intersect_box_unit.glsl;
#include ../../includes/gradient_methods.glsl;
#include ../../includes/lighting_phong.glsl;
#include ../../includes/color_mapping.glsl;
#include ../../includes/raycast_volume.glsl;
// #include ../../includes/raycast_volume_fast.glsl;
#include ../../includes/ray_step.glsl;

void main() {

    // gl_FragColor = vec4(vec3(1.0), 1.0);
    // return;

    // Normalize the view direction vector
    vec3 direction = normalize(v_direction);
    vec3 step = ray_step(direction, u_volume_voxel, u_raycast_resolution);            // Calculate the main ray step size

    // Compute the intersection of the ray with the unit box
    vec2 range = intersect_box_unit(v_camera, step);
    range = max(range, 0.0); // Ensure the range is non-negative

    if (range.x > range.y)     // Discard the fragment if the ray does not intersect the box
        discard; 

    // Perform raycasting to determine depth and value
    float value = 0.0;
    vec3 position = v_camera;

    bool hit = raycast_volume(u_volume_data, v_camera, step, range, position, value);

    if (hit) 
    {
        // Compute the gradient at the position
        float value_near = 0.0;
        vec3 normal_vector = gradient_methods(u_volume_data, position, u_volume_voxel, value_near);

        // Determine the maximum value for color mapping
        float value_max = max(value, value_near);    
        vec3 color = color_mapping(value_max);        

        // Apply Phong lighting model
        vec3 view_vector = v_camera - v_position;
        vec3 light_vector = view_vector + vec3(0.0, 0.2, 0.0);
        vec3 color_phong = lighting_phong(color, normal_vector, view_vector, light_vector);

        gl_FragColor = vec4(color_phong, 1.0);
        return;
    }

    discard; // Discard the fragment if no value is found

    // Include tone mapping and color space correction
    #include <tonemapping_fragment>
    #include <colorspace_fragment>
}
