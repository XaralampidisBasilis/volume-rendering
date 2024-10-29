

// derivatives_hermite_cubic
#if TRACE_DERIVATIVES_METHOD == 1  
    #include "./modules/derivatives_hermite_cubic"   

// derivatives_hermite_rational21
#elif TRACE_DERIVATIVES_METHOD == 2  
    #include "./modules/derivatives_hermite_rational21"   

// derivatives_hermite_rational12
#elif TRACE_DERIVATIVES_METHOD == 3  
    #include "./modules/derivatives_hermite_rational12"  

// derivatives_hermite_rational12
#elif TRACE_DERIVATIVES_METHOD == 4  
    #include "./modules/derivatives_hermite_rational22_nopoles" 

// derivatives_linear
#elif TRACE_DERIVATIVES_METHOD == 5
    #include "./modules/derivatives_linear" 

#else  
    #error "Unknown TRACE_DERIVATIVES_METHOD."

#endif // TRACE_DERIVATIVES_METHOD
