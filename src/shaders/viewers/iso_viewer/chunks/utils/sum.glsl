#ifndef SUM
#define SUM

// vec and ivec sum using dot product for compactness and efficiency
float sum(in vec2 v) { return dot(v, vec2(1.0)); }
float sum(in vec3 v) { return dot(v, vec3(1.0)); }
float sum(in vec4 v) { return dot(v, vec4(1.0)); }

int sum(in ivec2 v) { return int(dot(vec2(v), vec2(1.0))); }
int sum(in ivec3 v) { return int(dot(vec3(v), vec3(1.0))); }
int sum(in ivec4 v) { return int(dot(vec4(v), vec4(1.0))); }

#endif // SUM
