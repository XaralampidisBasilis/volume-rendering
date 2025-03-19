
if (block.intersected)
{
    #include "./compute_trace"
}
else
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
