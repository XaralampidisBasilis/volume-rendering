
#ifndef UNPACK_UINT_5551
#define UNPACK_UINT_5551

uvec4 unpack_uint_5551(in uint packed)
{
    return uvec4(
        (packed >> 11u) & 0x1Fu, // Extract bits 15–11: X distance
        (packed >>  6u) & 0x1Fu, // Extract bits 10–6:  Y distance
        (packed >>  1u) & 0x1Fu, // Extract bits 5–1:   Z distance
        (packed >>  0u) & 0x01u  // Extract bit 0:      Occupancy
    );
}

#endif