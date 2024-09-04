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
vec2 sdf_box(vec3 point, vec3 box_min, vec3 box_max)
{
    // Calculate the center and half-size of the box
    vec3 box_center = (box_max + box_min) * 0.5;
    vec3 box_halfsize = (box_max - box_min) * 0.5;

    // Calculate the absolute difference between the point and the box center
    vec3 q = abs(point - box_center);
    vec3 diff = q - box_halfsize;

    // Calculate the maximum and minimum distances
    vec2 dist = vec2
    (
        // Minimum distance of point to box 
        length(max(diff, 0.0) + min(max(diff.x,max(diff.y,diff.z)),0.0)),

        // Maximum distance of point to box 
        length(q + box_halfsize)
    );

    return dist;
}
