
if (block.intersected)
{
    #include "./compute_trace"
}

if (block.terminated)
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
