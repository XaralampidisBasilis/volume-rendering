#ifndef ARGMIN
#define ARGMIN

int argmin(in float a) { return 0; }
int argmin(in float a, in float b) { return (a < b) ? 0 : 1; }
int argmin(in float a, in float b, in float c) 
{ 
    return (a < b && a < c) ? 0 : ((b < c) ? 1 : 2); 
}
int argmin(in float a, in float b, in float c, in float d) 
{ 
    return (a < b && a < c && a < d) ? 0 :
           (b < c && b < d) ? 1 :
           (c < d) ? 2 : 3;
}

int argmin(in int a) { return 0; }
int argmin(in int a, in int b) { return (a < b) ? 0 : 1; }
int argmin(in int a, in int b, in int c) 
{ 
    return (a < b && a < c) ? 0 : ((b < c) ? 1 : 2); 
}
int argmin(in int a, in int b, in int c, in int d) 
{ 
    return (a < b && a < c && a < d) ? 0 :
           (b < c && b < d) ? 1 :
           (c < d) ? 2 : 3;
}

int argmin(const vec2 v) { return (v.x < v.y) ? 0 : 1; }
int argmin(const vec3 v) 
{ 
    return (v.x < v.y && v.x < v.z) ? 0 : ((v.y < v.z) ? 1 : 2); 
}
int argmin(const vec4 v) 
{ 
    return (v.x < v.y && v.x < v.z && v.x < v.w) ? 0 :
           (v.y < v.z && v.y < v.w) ? 1 :
           (v.z < v.w) ? 2 : 3;
}

int argmin(const ivec2 v) { return (v.x < v.y) ? 0 : 1; }
int argmin(const ivec3 v) 
{ 
    return (v.x < v.y && v.x < v.z) ? 0 : ((v.y < v.z) ? 1 : 2); 
}
int argmin(const ivec4 v) 
{ 
    return (v.x < v.y && v.x < v.z && v.x < v.w) ? 0 :
           (v.y < v.z && v.y < v.w) ? 1 :
           (v.z < v.w) ? 2 : 3;
}

#endif 
