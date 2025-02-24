
int get_octant_from_direction(in vec3 direction)
{
    // Convert direction signs to bit values (0 or 1)
    uvec3 bits = uvec3(step(0.0, direction));

    // Compute octant index using bitwise encoding
    return int((bits.z << 2) | (bits.y << 1) | bits.x);
}