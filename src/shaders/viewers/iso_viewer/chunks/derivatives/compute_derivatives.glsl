

// derivatives_hermite_cubic
#if DERIVATIVE_METHOD == 1  
    #include "./modules/derivatives_hermite_cubic"   

// derivatives_hermite_rational21
#elif DERIVATIVE_METHOD == 2  
    #include "./modules/derivatives_hermite_rational21"   

// derivatives_hermite_rational12
#elif DERIVATIVE_METHOD == 3  
    #include "./modules/derivatives_hermite_rational12"  

#else  
    #error "Unknown DERIVATIVE_METHOD."

#endif // DERIVATIVE_METHOD
