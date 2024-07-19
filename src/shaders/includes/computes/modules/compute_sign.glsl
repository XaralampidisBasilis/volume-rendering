
ivec3 compute_sign(ivec3 coordinates)
{
    return 2 * ivec3(lessThan(ivec3(0), coordinates)) - 1;
}