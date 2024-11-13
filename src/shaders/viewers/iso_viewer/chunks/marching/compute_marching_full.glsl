#include "./modules/start_trace"

while (trace.update) 
{
    #include "./modules/update_trace" 
}   

#include "./modules/end_trace"