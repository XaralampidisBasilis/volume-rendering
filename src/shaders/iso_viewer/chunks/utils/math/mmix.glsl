/*
contributors: Patricio Gonzalez Vivo
description: expands mix to linearly mix more than two values
use: <float|vec2|vec3|vec4> mmix(<float|vec2|vec3|vec4> a, <float|vec2|vec3|vec4> b, <float|vec2|vec3|vec4> c [, <float|vec2|vec3|vec4> d], <float> pct)
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/

#ifndef MMIX
#define MMIX

int    mmix(in int    a, in int    b, in int    pct) { return a + (b-a) * pct; }
ivec2  mmix(in ivec2  a, in ivec2  b, in int    pct) { return a + (b-a) * pct; }
ivec3  mmix(in ivec3  a, in ivec3  b, in int    pct) { return a + (b-a) * pct; }
ivec4  mmix(in ivec4  a, in ivec4  b, in int    pct) { return a + (b-a) * pct; }
ivec2  mmix(in ivec2  a, in ivec2  b, in ivec2  pct) { return a + (b-a) * pct; }
ivec3  mmix(in ivec3  a, in ivec3  b, in ivec3  pct) { return a + (b-a) * pct; }
ivec4  mmix(in ivec4  a, in ivec4  b, in ivec4  pct) { return a + (b-a) * pct; }

float mmix(in float a, in float b, in float pct) { return mix(a, b, pct); }
vec2  mmix(in vec2  a, in vec2  b, in float pct) { return mix(a, b, pct); }
vec3  mmix(in vec3  a, in vec3  b, in float pct) { return mix(a, b, pct); }
vec4  mmix(in vec4  a, in vec4  b, in float pct) { return mix(a, b, pct); }
vec2  mmix(in vec2  a, in vec2  b, in vec2  pct) { return mix(a, b, pct); }
vec3  mmix(in vec3  a, in vec3  b, in vec3  pct) { return mix(a, b, pct); }
vec4  mmix(in vec4  a, in vec4  b, in vec4  pct) { return mix(a, b, pct); }

float mmix(in float a, in float b, in float c, in float pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

vec2 mmix(vec2 a, vec2 b, vec2 c, float pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

vec2 mmix(vec2 a, vec2 b, vec2 c, vec2 pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

vec3 mmix(vec3 a, vec3 b, vec3 c, float pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

vec3 mmix(vec3 a, vec3 b, vec3 c, vec3 pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

vec4 mmix(vec4 a, vec4 b, vec4 c, float pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

vec4 mmix(vec4 a, vec4 b, vec4 c, vec4 pct) {
    return mix(
        mix(a, b, 2. * pct),
        mix(b, c, 2. * (max(pct, .5) - .5)),
        step(.5, pct)
    );
}

float mmix(in float a, in float b, in float c, in float d, in float pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

vec2 mmix(in vec2 a, in vec2 b, in vec2 c, in vec2 d, in float pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

vec2 mmix(in vec2 a, in vec2 b, in vec2 c, in vec2 d, in vec2 pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

vec3 mmix(in vec3 a, in vec3 b, in vec3 c, in vec3 d, in float pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

vec3 mmix(in vec3 a, in vec3 b, in vec3 c, in vec3 d, in vec3 pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

vec4 mmix(in vec4 a, in vec4 b, in vec4 c, in vec4 d, in float pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

vec4 mmix(in vec4 a, in vec4 b, in vec4 c, in vec4 d, in vec4 pct) {
    return mix(
        mix(a, b, 3. * pct),
        mix(b,
            mix( c,
                d,
                3. * (max(pct, .66) - .66)),
            3. * (clamp(pct, .33, .66) - .33)
        ),
        step(.33, pct)
    );
}

// Element-wise mix for mat2
mat2 mmix(mat2 A, mat2 B, float alpha) {
    return mat2(
        mix(A[0], B[0], alpha),
        mix(A[1], B[1], alpha)
    );
}

// Element-wise mix for mat3
mat3 mmix(mat3 A, mat3 B, float alpha) {
    return mat3(
        mix(A[0], B[0], alpha),
        mix(A[1], B[1], alpha),
        mix(A[2], B[2], alpha)
    );
}

// Element-wise mix for mat4
mat4 mmix(mat4 A, mat4 B, float alpha) {
    return mat4(
        mix(A[0], B[0], alpha),
        mix(A[1], B[1], alpha),
        mix(A[2], B[2], alpha),
        mix(A[3], B[3], alpha)
    );
}

// Element-wise mix for mat2x3 (2 columns, 3 rows)
mat2x3 mmix(mat2x3 A, mat2x3 B, float alpha) {
    return mat2x3(
        mix(A[0], B[0], alpha), // vec3
        mix(A[1], B[1], alpha)  // vec3
    );
}

// Element-wise mix for mat3x2 (3 columns, 2 rows)
mat3x2 mmix(mat3x2 A, mat3x2 B, float alpha) {
    return mat3x2(
        mix(A[0], B[0], alpha), // vec2
        mix(A[1], B[1], alpha), // vec2
        mix(A[2], B[2], alpha)  // vec2
    );
}

// Element-wise mix for mat2x4 (2 columns, 4 rows)
mat2x4 mmix(mat2x4 A, mat2x4 B, float alpha) {
    return mat2x4(
        mix(A[0], B[0], alpha), // vec4
        mix(A[1], B[1], alpha)  // vec4
    );
}

// Element-wise mix for mat4x2 (4 columns, 2 rows)
mat4x2 mmix(mat4x2 A, mat4x2 B, float alpha) {
    return mat4x2(
        mix(A[0], B[0], alpha),
        mix(A[1], B[1], alpha),
        mix(A[2], B[2], alpha),
        mix(A[3], B[3], alpha)
    );
}

// Element-wise mix for mat3x4 (3 columns, 4 rows)
mat3x4 mmix(mat3x4 A, mat3x4 B, float alpha) {
    return mat3x4(
        mix(A[0], B[0], alpha),
        mix(A[1], B[1], alpha),
        mix(A[2], B[2], alpha)
    );
}

// Element-wise mix for mat4x3 (4 columns, 3 rows)
mat4x3 mmix(mat4x3 A, mat4x3 B, float alpha) {
    return mat4x3(
        mix(A[0], B[0], alpha),
        mix(A[1], B[1], alpha),
        mix(A[2], B[2], alpha),
        mix(A[3], B[3], alpha)
    );
}


#endif // MMIX