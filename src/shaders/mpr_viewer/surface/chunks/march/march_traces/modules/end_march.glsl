
if (trace.intersected)
{
    #include "./end_trace"
}
else
{
    #if DISCARDING_DISABLED == 0
    discard;  
    #endif
}
