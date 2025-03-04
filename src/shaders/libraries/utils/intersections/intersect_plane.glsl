
#ifndef INTERSECT_PLANE
#define INTERSECT_PLANE

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef INFINITY
#define INFINITY 3.402823e38
#endif

float intersect_plane(vec4 hessian, vec3 origin, vec3 direction) 
{
    float denominator = dot(hessian.xyz, direction);
    if ( abs(denominator) < MICRO_TOLERANCE ) 
    {
        return INFINITY;
    }

    float distance = -(dot( hessian.xyz, origin) + hessian.w) / denominator;
    if ( distance < 0.0 ) 
    {
        return INFINITY;
    }

    return distance;
}

#endif 