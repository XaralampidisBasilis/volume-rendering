#ifndef ARGMIN
#define ARGMIN

int argmin(in float x) 
{ 
    return 0; 
}
int argmin(in int x) 
{ 
    return 0; 
}
int argmin(in float x, in float y) 
{
    return (x <= y) ? 0 : 1; 
}
int argmin(in int x, in int y) 
{ 
    return (x <= y) ? 0 : 1; 
}
int argmin(in vec2 v) 
{ 
    return (v.x <= v.y) ? 0 : 1; 
}
int argmin(in ivec2 v) 
{ 
    return (v.x <= v.y) ? 0 : 1; 
}
int argmin(in float x, in float y, in float z) 
{ 
    return (x <= y) ? ((x <= z) ? 0 : 2) 
                    : ((y <= z) ? 1 : 2);
}
int argmin(in int x, in int y, in int z) 
{ 
    return (x <= y) ? ((x <= z) ? 0 : 2) 
                    : ((y <= z) ? 1 : 2);
}
int argmin(in vec3 v) 
{ 
    return (v.x <= v.y) ? ((v.x <= v.z) ? 0 : 2) 
                        : ((v.y <= v.z) ? 1 : 2);
}
int argmin(in ivec3 v) 
{ 
    return (v.x <= v.y) ? ((v.x <= v.z) ? 0 : 2) 
                        : ((v.y <= v.z) ? 1 : 2);
}
int argmin(in float x, in float y, in float z, in float w)
{ 
    return (x <= y) ? ((x <= z) ? ((x <= w) ? 0 : 3) 
                                : ((z <= w) ? 2 : 3)) 
                    : ((y <= z) ? ((y <= w) ? 1 : 3) 
                                : ((z <= w) ? 2 : 3));
}
int argmin(in int x, in int y, in int z, in int w) 
{ 
    return (x <= y) ? ((x <= z) ? ((x <= w) ? 0 : 3) 
                                : ((z <= w) ? 2 : 3)) 
                    : ((y <= z) ? ((y <= w) ? 1 : 3) 
                                : ((z <= w) ? 2 : 3));
}
int argmin(in vec4 v) 
{ 
    return (v.x <= v.y) ? ((v.x <= v.z) ? ((v.x <= v.w) ? 0 : 3) 
                                        : ((v.z <= v.w) ? 2 : 3)) 
                        : ((v.y <= v.z) ? ((v.y <= v.w) ? 1 : 3) 
                                        : ((v.z <= v.w) ? 2 : 3));
}
int argmin(in ivec4 v) 
{ 
    return (v.x <= v.y) ? ((v.x <= v.z) ? ((v.x <= v.w) ? 0 : 3) 
                                        : ((v.z <= v.w) ? 2 : 3)) 
                        : ((v.y <= v.z) ? ((v.y <= v.w) ? 1 : 3) 
                                        : ((v.z <= v.w) ? 2 : 3));
}

#endif 
