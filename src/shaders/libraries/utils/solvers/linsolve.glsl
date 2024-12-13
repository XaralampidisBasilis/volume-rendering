#ifndef LINSOLVE
#define LINSOLVE

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef SUM
#include "../sum"
#endif

vec2 linsolve(in mat2 A, in vec2 b)
{
    // compute the matrix norm (maximum absolute row sum norm)
    float matrix_norm = 0.0;
    matrix_norm += max(matrix_norm, sum(abs(A[0]))); 
    matrix_norm += max(matrix_norm, sum(abs(A[1]))); 

    // compute tolerance
    float tolerance = matrix_norm * MICRO_TOLERANCE;
    tolerance = max(tolerance, NANO_TOLERANCE);

    // apply small regularization 
    float singular = step(abs(determinant(A)), tolerance); 
    A[0][0] += tolerance * singular;
    A[1][1] += tolerance * singular;

    // solve linear system
    return inverse(A) * b;
}

vec3 linsolve(in mat3 A, in vec3 b)
{
    // compute the matrix norm (maximum absolute row sum norm)
    float matrix_norm = 0.0;
    matrix_norm += max(matrix_norm, sum(abs(A[0]))); 
    matrix_norm += max(matrix_norm, sum(abs(A[1]))); 
    matrix_norm += max(matrix_norm, sum(abs(A[2]))); 

    // compute tolerance
    float tolerance = matrix_norm * MICRO_TOLERANCE;
    tolerance = max(tolerance, NANO_TOLERANCE);

    // apply small regularization 
    float singular = step(abs(determinant(A)), tolerance); 
    A[0][0] += tolerance * singular;
    A[1][1] += tolerance * singular;
    A[2][2] += tolerance * singular;

    // solve linear system
    return inverse(A) * b;
}

vec4 linsolve(in mat4 A, in vec4 b)
{
    // compute the matrix norm (maximum absolute row sum norm)
    float matrix_norm = 0.0;
    matrix_norm += max(matrix_norm, sum(abs(A[0]))); 
    matrix_norm += max(matrix_norm, sum(abs(A[1]))); 
    matrix_norm += max(matrix_norm, sum(abs(A[2]))); 
    matrix_norm += max(matrix_norm, sum(abs(A[3]))); 

    // compute tolerance
    float tolerance = matrix_norm * MICRO_TOLERANCE;
    tolerance = max(tolerance, NANO_TOLERANCE);

    // apply small regularization 
    float singular = step(abs(determinant(A)), tolerance); 
    A[0][0] += tolerance * singular;
    A[1][1] += tolerance * singular;
    A[2][2] += tolerance * singular;
    A[3][3] += tolerance * singular;

    // solve linear system
    return inverse(A) * b;
}

#endif // LINSOLVE