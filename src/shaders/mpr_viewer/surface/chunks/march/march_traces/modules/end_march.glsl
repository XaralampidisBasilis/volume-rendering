
if (trace.intersected)
{
    #include "./compute_gradient"
}
else
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
