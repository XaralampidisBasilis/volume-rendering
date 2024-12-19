#ifndef CUBIC_MAXIMA
#define CUBIC_MAXIMA

#ifndef QUADRATIC_SOLVER
#include "./quadratic_solver"
#endif
#ifndef INSIDE_OPEN
#include "../inclusions/inside_open"
#endif
#ifndef CUBIC_POWS
#include "./cubic_pows"
#endif
#ifndef MMAX
#include "../mmax"
#endif

void cubic_maxima(out float maxima_value, in vec4 coeffs, in vec2 boundary_points)
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

    // compute maxima values
    maxima_value = mmax(critical_values);
}

void cubic_maxima(out float maxima_value, out float maxima_point, in vec4 coeffs, in vec2 boundary_points)
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

    // compute maxima value
    maxima_value = mmax(critical_values);

    // compute maxima masks
    vec4 is_maxima = vec4(equal(critical_values, vec4(maxima_value)));

    // compute maxima point
    maxima_point = dot(is_maxima, critical_points);
}

void cubic_maxima(out float maxima_value, in vec4 coeffs, in vec2 boundary_points, in vec2 boundary_values)
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

    // compute maxima value
    maxima_value = mmax(critical_values);
}

void cubic_maxima(out float maxima_value, out float maxima_point, in vec4 coeffs, in vec2 boundary_points, in vec2 boundary_values)
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

    // compute maxima value
    maxima_value = mmax(critical_values);

    // compute maxima masks
    vec4 is_maxima = vec4(equal(critical_values, vec4(maxima_value)));

    // compute maxima point
    maxima_point = dot(is_maxima, critical_points);
}

#endif
