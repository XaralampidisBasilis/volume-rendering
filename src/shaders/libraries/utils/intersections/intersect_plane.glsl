
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
    float denominator = dot(hessian, vec4(direction, 0.0));
    float distance = -dot(hessian, vec4(origin, 1.0)) / denominator;

    if ( abs(denominator) < MICRO_TOLERANCE ) 
    {
        return INFINITY;
    }

    return distance;
}

#endif 