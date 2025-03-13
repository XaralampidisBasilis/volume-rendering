#ifndef ARGMIN
#define ARGMIN

int argmin(in float x) 
{ 
    return 0; 
}
int argmin(in vec2 v) 
{ 
    return int(v.x > v.y); 
}
int argmin(in vec3 v) 
{ 
    int n = int(v.x > v.y);
    n += int(v[n] > v.z) * (2 - n);
    return n;
}
int argmin(in vec4 v) 
{ 
    int n = int(v.x > v.y);
    n += int(v[n] > v.z) * (2 - n);
    n += int(v[n] > v.w) * (3 - n);
    return n;
}

int argmin(in int x) 
{ 
    return 0; 
}
int argmin(in ivec2 v) 
{ 
    return int(v.x > v.y); 
}
int argmin(in ivec3 v) 
{ 
    int n = int(v.x > v.y);
    n += int(v[n] > v.z) * (2 - n);
    return n;
}
int argmin(in ivec4 v) 
{ 
    int n = int(v.x > v.y);
    n += int(v[n] > v.z) * (2 - n);
    n += int(v[n] > v.w) * (3 - n);
    return n;
}

int argmin(in float x, in float y) 
{ 
    return argmin(vec2(x, y)); 
}
int argmin(in float x, in float y, in float z) 
{ 
    return argmin(vec3(x, y, z));
}
int argmin(in float x, in float y, in float z, in float w) 
{ 
    return argmin(vec4(x, y, z, w));
}

int argmin(in int x, in int y) 
{ 
    return argmin(vec2(x, y)); 
}
int argmin(in int x, in int y, in int z) 
{ 
    return argmin(vec3(x, y, z));
}
int argmin(in int x, in int y, in int z, in int w) 
{ 
    return argmin(vec4(x, y, z, w));
}

#endif 
