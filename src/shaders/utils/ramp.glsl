float ramp(float edge0, float edge1, float x) 
{
    return max(0.0, min(1.0, (x - edge0) / (edge1 - edge0)));
}