#ifndef SORT
#define SORT

vec2 sort(in vec2 v)
{
    return mix(v.xy, v.yx, step(v.y, v.x));
}
vec3 sort(in vec3 v)
{
    v.xy = mix(v.xy, v.yx, step(v.y, v.x)); // Swap x and y if x > y
    v.yz = mix(v.yz, v.zy, step(v.z, v.y)); // Swap y and z if y > z
    v.xy = mix(v.xy, v.yx, step(v.y, v.x)); // Final check for x and y
    return v;
}
vec4 sort(in vec4 v) 
{
    v.xy = mix(v.xy, v.yx, step(v.y, v.x)); // Swap x and y if x > y
    v.zw = mix(v.zw, v.wz, step(v.w, v.z)); // Swap z and w if z > w
    v.yz = mix(v.yz, v.zy, step(v.z, v.y)); // Swap y and z if y > z
    v.xy = mix(v.xy, v.yx, step(v.y, v.x)); // Final check for x and y
    v.zw = mix(v.zw, v.wz, step(v.w, v.z)); // Final check for z and w
    return v;
}

// vec2 sort(in vec2 v)
// {
//     return (v.y > v.x) ? v.xy : v.yx;
// }
// vec3 sort(in vec3 v)
// {
//     v.xy = (v.y > v.x) ? v.xy : v.yx; // Swap x and y if x > y
//     v.yz = (v.z > v.y) ? v.yz : v.zy; // Swap y and z if y > z
//     v.xy = (v.y > v.x) ? v.xy : v.yx; // Final check for x and y
//     return v;
// }
// vec4 sort(in vec4 v) 
// {
//     v.xy = (v.y > v.x) ? v.xy : v.yx; // Swap x and y if x > y
//     v.zw = (v.w > v.z) ? v.zw : v.wz; // Swap z and w if z > w
//     v.yz = (v.z > v.y) ? v.yz : v.zy; // Swap y and z if y > z
//     v.xy = (v.y > v.x) ? v.xy : v.yx; // Final check for x and y
//     v.zw = (v.w > v.z) ? v.zw : v.wz; // Final check for z and w
//     return v;
// }

#endif // SORT

