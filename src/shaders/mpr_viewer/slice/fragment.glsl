precision highp sampler3D;
precision highp sampler2D;
precision highp float;
precision highp int;

in vec2 vUv;

out vec4 fragColor;

#include "./chunks/uniforms/uniforms"

void main() 
{
    fragColor = vec4(vUv, 0.0, 1.0); 
}