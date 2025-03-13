#ifndef ARGMAX
#define ARGMAX

int argmax(in float x) 
{ 
    return 0; 
}
int argmax(in vec2 v) 
{ 
    return int(v.x < v.y); 
}
int argmax(in vec3 v) 
{ 
    int n = int(v.x < v.y);
    n += int(v[n] < v.z) * (2 - n);
    return n;
}
int argmax(in vec4 v) 
{ 
    int n = int(v.x < v.y);
    n += int(v[n] < v.z) * (2 - n);
    n += int(v[n] < v.w) * (3 - n);
    return n;
}

int argmax(in int x) 
{ 
    return 0; 
}
int argmax(in ivec2 v) 
{ 
    return int(v.x < v.y); 
}
int argmax(in ivec3 v) 
{ 
    int n = int(v.x < v.y);
    n += int(v[n] < v.z) * (2 - n);
    return n;
}
int argmax(in ivec4 v) 
{ 
    int n = int(v.x < v.y);
    n += int(v[n] < v.z) * (2 - n);
    n += int(v[n] < v.w) * (3 - n);
    return n;
}

int argmax(in float x, in float y) 
{ 
    return argmax(vec2(x, y)); 
}
int argmax(in float x, in float y, in float z) 
{ 
    return argmax(vec3(x, y, z));
}
int argmax(in float x, in float y, in float z, in float w) 
{ 
    return argmax(vec4(x, y, z, w));
}

int argmax(in int x, in int y) 
{ 
    return argmax(vec2(x, y)); 
}
int argmax(in int x, in int y, in int z) 
{ 
    return argmax(vec3(x, y, z));
}
int argmax(in int x, in int y, in int z, in int w) 
{ 
    return argmax(vec4(x, y, z, w));
}

#endif 
