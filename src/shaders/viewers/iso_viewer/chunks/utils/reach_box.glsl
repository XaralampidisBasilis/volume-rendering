/**
 * Calculates the minimum and maximum distance from a point to a 3D box.
 *
 * @param point     The 3D point in space.
 * @param box_min   The minimum corner (bottom-left-front) of the 3D box.
 * @param box_max   The maximum corner (top-right-back) of the 3D box.
 * @return vec2     A vec2 where:
 *                  - x is the maximum distance from the point to the box.
 *                  - y is the minimum distance from the point to the box.
 */

 vec2 reach_box(vec2 b_min, vec2 b_max, vec2 p) {
    // compute the center and half-size of the box
    // compute the absolute difference between the point and the box center
    // compute the maximum and minimum bounding distances
    vec2 c = (b_max + b_min) / 2.0;
    vec2 s = (b_max - b_min) / 2.0;
    vec2 b = abs(p - c);
    return  vec2(length(max(b - s, 0.0)), length(b + s));
}

vec2 reach_box(vec3 b_min, vec3 b_max, vec3 p) {
    // compute the center and half-size of the box
    // compute the absolute difference between the point and the box center
    // compute the maximum and minimum bounding distances
    vec3 c = (b_max + b_min) / 2.0;
    vec3 s = (b_max - b_min) / 2.0;
    vec3 b = abs(p - c);
    return  vec2(length(max(b - s, 0.0)), length(b + s));
}

vec2 reach_box(vec4 b_min, vec4 b_max, vec4 p) {
    // compute the center and half-size of the box
    // compute the absolute difference between the point and the box center
    // compute the maximum and minimum bounding distances
    vec4 c = (b_max + b_min) / 2.0;
    vec4 s = (b_max - b_min) / 2.0;
    vec4 b = abs(p - c);
    return  vec2(length(max(b - s, 0.0)), length(b + s));
}



