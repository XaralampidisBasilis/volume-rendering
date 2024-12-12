#ifndef MATH_CONSTANTS
#define MATH_CONSTANTS

struct MathConstants {
    float QTR_PI;
    float HALF_PI;
    float PI;
    float TWO_PI;
    float TAU;
    float INV_PI;
    float INV_SQRT_TAU;
    float SQRT_HALF_PI;
    float PHI;
    float GOLDEN_RATIO;
    float GOLDEN_RATIO_CONJUGATE;
    float GOLDEN_ANGLE;
    float EULER;
    float SQRT_2;         
    float SQRT_3;         
    float SQRT_5;         
    float LN_2;           
    float LN_10;          
    float LOG2_E;         
    float LOG10_E;        
    float DEG_TO_RAD;     
    float RAD_TO_DEG;     
    float CATALAN;        
    float APERY;          
};

const MathConstants MATH = MathConstants(
    0.78539816339,   
    1.57079632679,   
    3.14159265359,   
    6.28318530718,   
    6.28318530718,   
    0.31830988618,   
    0.39894228040,   
    1.25331413732,   
    1.61803398875,   
    1.61803398875,   
    0.61803398875,   
    2.39996323,      
    2.71828182846,   
    1.41421356237,   
    1.73205080757,   
    2.23606797750,   
    0.69314718056,   
    2.30258509299,   
    1.44269504089,   
    0.43429448190,   
    0.01745329252,   
    57.2957795131,   
    0.91596559417,   
    1.20205690316    
);

#endif
