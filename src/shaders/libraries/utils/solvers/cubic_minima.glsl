#ifndef CUBIC_MINIMA
#define CUBIC_MINIMA

#ifndef QUADRATIC_SOLVER
#include "./quadratic_solver"
#endif
#ifndef INSIDE_OPEN
#include "../inclusions/inside_open"
#endif
#ifndef CUBIC_POWS
#include "./cubic_pows"
#endif
#ifndef MMIN
#include "../mmin"
#endif

void cubic_minima(out float minima_value, in vec4 coeffs, in vec2 boundary_points)
{
    // critical points and values
    vec4 critical_points;
    vec4 critical_values;

    // compute boundary points
    critical_points.xw = boundary_points;

    // compute boundary values
    critical_values.x = dot(coeffs, cubic_pows(critical_points.x));
    critical_values.w = dot(coeffs, cubic_pows(critical_points.w));
   
    // compute the critical points
    vec3 derivative_coeffs = coeffs.yzw * vec3(1.0, 2.0, 3.0);
    critical_points.yz = quadratic_solver(derivative_coeffs, 0.0, boundary_points.x);

    // compute the critical values
    critical_values.y = dot(coeffs, cubic_pows(critical_points.y));
    critical_values.z = dot(coeffs, cubic_pows(critical_points.z));

    // clamp values outside the boundary
    vec2 is_inside = inside_open(boundary_points.x, boundary_points.y, critical_points.yz);
    critical_values.yz = mix(critical_values.xw, critical_values.yz, is_inside);

    // compute minima values
    minima_value = mmin(critical_values);
}

void cubic_minima(out float minima_value, out float minima_point, in vec4 coeffs, in vec2 boundary_points)
{
    // critical points and values
    vec4 critical_points;
    vec4 critical_values;

    // compute boundary points
    critical_points.xw = boundary_points;

    // compute boundary values
    critical_values.x = dot(coeffs, cubic_pows(critical_points.x));
    critical_values.w = dot(coeffs, cubic_pows(critical_points.w));
   
    // compute the critical points
    vec3 derivative_coeffs = coeffs.yzw * vec3(1.0, 2.0, 3.0);
    critical_points.yz = quadratic_solver(derivative_coeffs, 0.0, boundary_points.x);

    // compute the critical values
    critical_values.y = dot(coeffs, cubic_pows(critical_points.y));
    critical_values.z = dot(coeffs, cubic_pows(critical_points.z));

    // clamp values outside the boundary
    vec2 is_inside = inside_open(boundary_points.x, boundary_points.y, critical_points.yz);
    critical_values.yz = mix(critical_values.xw, critical_values.yz, is_inside);

    // compute minima value
    minima_value = mmin(critical_values);

    // compute minima masks
    vec4 is_minima = vec4(equal(critical_values, vec4(minima_value)));

    // compute minima point
    minima_point = dot(is_minima, critical_points);
}

void cubic_minima( out float minima_value, in vec4 coeffs, in vec2 boundary_points, in vec2 boundary_values)
{
    // critical points and values
    vec4 critical_points;
    vec4 critical_values;

    // compute boundary points
    critical_points.xw = boundary_points;

    // compute boundary values
    critical_values.xw = boundary_values;
   
    // compute the critical points
    vec3 derivative_coeffs = coeffs.yzw * vec3(1.0, 2.0, 3.0);
    critical_points.yz = quadratic_solver(derivative_coeffs, 0.0, boundary_points.x);

    // compute the critical values
    critical_values.y = dot(coeffs, cubic_pows(critical_points.y));
    critical_values.z = dot(coeffs, cubic_pows(critical_points.z));

    // clamp values outside the boundary
    vec2 is_inside = inside_open(boundary_points.x, boundary_points.y, critical_points.yz);
    critical_values.yz = mix(boundary_values, critical_values.yz, is_inside);

    // compute minima value
    minima_value = mmin(critical_values);
}

void cubic_minima(out float minima_value, out float minima_point, in vec4 coeffs, in vec2 boundary_points, in vec2 boundary_values)
{
    // critical points and values
    vec4 critical_points;
    vec4 critical_values;

    // compute boundary points
    critical_points.xw = boundary_points;

    // compute boundary values
    critical_values.xw = boundary_values;

    // compute the critical points
    vec3 derivative_coeffs = coeffs.yzw * vec3(1.0, 2.0, 3.0);
    critical_points.yz = quadratic_solver(derivative_coeffs, 0.0, boundary_points.x);

    // compute the critical values
    critical_values.y = dot(coeffs, cubic_pows(critical_points.y));
    critical_values.z = dot(coeffs, cubic_pows(critical_points.z));

    // clamp values outside the boundary
    vec2 is_inside = inside_open(boundary_points.x, boundary_points.y, critical_points.yz);
    critical_values.yz = mix(boundary_values, critical_values.yz, is_inside);

    // compute minima value
    minima_value = mmin(critical_values);

    // compute minima masks
    vec4 is_minima = vec4(equal(critical_values, vec4(minima_value)));

    // compute minima point
    minima_point = dot(is_minima, critical_points);
}

#endif
