#ifndef PROD
#define PROD

float prod(in float v) { return v; }
float prod(in vec2  v) { return v.x * v.y; }
float prod(in vec3  v) { return v.x * v.y * v.z; }
float prod(in vec4  v) { return v.x * v.y * v.z * v.w; }

int   prod(in int   v) { return v; }
int   prod(in ivec2 v) { return v.x * v.y; }
int   prod(in ivec3 v) { return v.x * v.y * v.z; }
int   prod(in ivec4 v) { return v.x * v.y * v.z * v.w; }
  
#endif // PROD
