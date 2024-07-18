#include "cubic.hlsl"

/*
contributors: Patricio Gonzalez Vivo
description: cubic polynomial interpolation between two values
use: <float|float2|float3|float4> cubicMix(<float|float2|float3|float4> A, <float|float2|float3|float4> B, float t)
examples:
    - https://raw.githubusercontent.com/patriciogonzalezvivo/lygia_examples/main/math_functions.frag
*/

#ifndef FNC_CUBICMIX
#define FNC_CUBICMIX
float cubicMix(float A, float B, float t) { return A + (B - A) * cubic(t); }
float2 cubicMix(float2 A, float2 B, float t) { return A + (B - A) * cubic(t); }
float2 cubicMix(float2 A, float2 B, float2 t) { return A + (B - A) * cubic(t); }
float3 cubicMix(float3 A, float3 B, float t) { return A + (B - A) * cubic(t); }
float3 cubicMix(float3 A, float3 B, float3 t) { return A + (B - A) * cubic(t); }
float4 cubicMix(float4 A, float4 B, float t) { return A + (B - A) * cubic(t); }
float4 cubicMix(float4 A, float4 B, float4 t) { return A + (B - A) * cubic(t); }
#endif