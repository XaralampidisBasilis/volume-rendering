#include "./modules/start_trace"

for (trace.distance = ray.start_distance; trace.distance < ray.end_distance; ) 
{
    #include "./modules/update_trace" 
}   

#include "./modules/end_trace"