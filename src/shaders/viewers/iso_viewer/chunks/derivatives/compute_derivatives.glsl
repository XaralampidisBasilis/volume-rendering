

// derivatives_hermite_cubic
#if TRACE_DERIVATIVES_METHOD == 1  
    #include "./modules/derivatives_hermite_cubic"   

// derivatives_hermite_21
#elif TRACE_DERIVATIVES_METHOD == 2  
    #include "./modules/derivatives_hermite_21"   

// derivatives_hermite_12
#elif TRACE_DERIVATIVES_METHOD == 3  
    #include "./modules/derivatives_hermite_12"  

// derivatives_hermite_22p
#elif TRACE_DERIVATIVES_METHOD == 4  
    #include "./modules/derivatives_hermite_22p" 

// derivatives_linear
#elif TRACE_DERIVATIVES_METHOD == 5
    #include "./modules/derivatives_linear" 

#else  
    #error "Unknown TRACE_DERIVATIVES_METHOD."

#endif // TRACE_DERIVATIVES_METHOD
