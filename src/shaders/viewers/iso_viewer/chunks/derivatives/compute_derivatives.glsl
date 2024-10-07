

// derivative_hermite30
#if DERIVATIVE_METHOD == 1  
    #include "./modules/derivative_hermite30"   

// derivative_hermite21
#elif DERIVATIVE_METHOD == 2  
    #include "./modules/derivative_hermite21"   

// derivative_hermite12
#elif DERIVATIVE_METHOD == 3  
    #include "./modules/derivative_hermite12"  

#else  
    #error "Unknown DERIVATIVE_METHOD."

#endif // DERIVATIVE_METHOD
