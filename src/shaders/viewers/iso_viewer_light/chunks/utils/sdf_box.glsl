/**
 * Calculates the minimum and maximum distance from a point to a 3D box.
 *
 * @param point     The 3D point in space.
 * @param box_min   The minimum corner (bottom-left-front) of the 3D box.
 * @param box_max   The maximum corner (top-right-back) of the 3D box.
 * @return float    The min distance from the point to the box.
 */

#ifndef SDF_BOX
#define SDF_BOX

float sdf_box(vec2 b_min, vec2 b_max, vec2 p) 
{
    vec2 c = (b_max + b_min) / 2.0;
    vec2 s = (b_max - b_min) / 2.0;
    vec2 d_min = abs(p - c) - s;
    return length(max(d_min, 0.0) + min(mmax(d_min), 0.0));
}

float sdf_box(vec2 b_min, vec2 b_max, vec2 p, out vec2 v_min) 
{
    vec2 c = (b_max + b_min) / 2.0;
    vec2 s = (b_max - b_min) / 2.0;
    vec2 q = p - c;
    vec2 d_min = abs(q) - s;

    v_min = max(d_min, 0.0) + min(mmax(d_min), 0.0);
    v_min *= sign(q);

    return length(v_min);
}

float sdf_box(vec3 b_min, vec3 b_max, vec3 p) 
{
    vec3 c = (b_max + b_min) / 2.0;
    vec3 s = (b_max - b_min) / 2.0;
    vec3 d_min = abs(p - c) - s;
    return length(max(d_min, 0.0) + min(mmax(d_min), 0.0));
}

float sdf_box(vec3 b_min, vec3 b_max, vec3 p, out vec3 v_min) 
{
    vec3 c = (b_max + b_min) / 2.0;
    vec3 s = (b_max - b_min) / 2.0;
    vec3 q = p - c;
    vec3 d_min = abs(q) - s;

    v_min = max(d_min, 0.0) + min(mmax(d_min), 0.0);
    v_min *= sign(q);

    return length(v_min);
}

vec2 sdf_box_bounds(vec2 b_min, vec2 b_max, vec2 p) 
{
    vec2 c = (b_max + b_min) / 2.0;
    vec2 s = (b_max - b_min) / 2.0;
    vec2 aq = abs(p - c);
    vec2 d_min = aq - s;
    vec2 d_max = aq + s;
    return vec2(length(max(d_min, 0.0) + min(mmax(d_min), 0.0)), length(d_max));
}

vec2 sdf_box_bounds(vec2 b_min, vec2 b_max, vec2 p, out vec2 v_min, out vec2 v_max) 
{
    vec2 c = (b_max + b_min) / 2.0;
    vec2 s = (b_max - b_min) / 2.0;
    vec2 q = p - c;
    vec2 aq = abs(q);
    vec2 sq = sign(q);
    vec2 d_min = aq - s;
    vec2 d_max = aq + s;

    v_min = (max(d_min, 0.0) + min(mmax(d_min), 0.0)) * sq;
    v_max = d_max * sq;

    return vec2(length(v_min), length(v_max));
}

vec2 sdf_box_bounds(vec3 b_min, vec3 b_max, vec3 p) 
{
    vec3 c = (b_max + b_min) / 2.0;
    vec3 s = (b_max - b_min) / 2.0;
    vec3 aq = abs(p - c);
    vec3 d_min = aq - s;
    vec3 d_max = aq + s;    
    return vec2(length(max(d_min, 0.0) + min(mmax(d_min), 0.0)), length(d_max));
}

vec2 sdf_box_bounds(vec3 b_min, vec3 b_max, vec3 p, out vec3 v_min, out vec3 v_max) 
{
    vec3 c = (b_max + b_min) / 2.0;
    vec3 s = (b_max - b_min) / 2.0;
    vec3 q = p - c;
    vec3 aq = abs(q);
    vec3 sq = sign(q);
    vec3 d_min = aq - s;
    vec3 d_max = aq + s;

    v_min = (max(d_min, 0.0) + min(mmax(d_min), 0.0)) * sq;
    v_max = d_max * sq;

    return vec2(length(v_min), length(v_max));
}

#endif // SDF_BOX
