#include "./modules/start_trace"
#include "./modules/update_condition" 

while (trace.update) 
{
    #include "./modules/update_trace" 
    #include "./modules/update_condition" 
}   

#include "./modules/end_trace"