/*
contributors: Patricio Gonzalez Vivo
description: some useful math constants
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/
#ifndef CONSTANTS
#define CONSTANTS

    // MATHEMATICAL CONSTANTS
    #ifndef QTR_PI
    #define QTR_PI 0.78539816339
    #endif
    #ifndef HALF_PI
    #define HALF_PI 1.5707963267948966192313216916398
    #endif
    #ifndef PI
    #define PI 3.1415926535897932384626433832795
    #endif
    #ifndef TWO_PI
    #define TWO_PI 6.2831853071795864769252867665590
    #endif
    #ifndef TAU
    #define TAU 6.2831853071795864769252867665590
    #endif
    #ifndef INV_PI
    #define INV_PI 0.31830988618379067153776752674503
    #endif
    #ifndef INV_SQRT_TAU
    #define INV_SQRT_TAU 0.39894228040143267793994605993439  // 1.0/SQRT_TAU
    #endif
    #ifndef SQRT_HALF_PI
    #define SQRT_HALF_PI 1.25331413732
    #endif
    #ifndef PHI
    #define PHI 1.618033988749894848204586834
    #endif
    #ifndef GOLDEN_RATIO
    #define GOLDEN_RATIO 1.6180339887
    #endif
    #ifndef GOLDEN_RATIO_CONJUGATE 
    #define GOLDEN_RATIO_CONJUGATE 0.61803398875
    #endif
    #ifndef GOLDEN_ANGLE // (3.-sqrt(5.0))*PI radians
    #define GOLDEN_ANGLE 2.39996323
    #endif
    #ifndef EULER
    #define EULER 2.718281828459045235360287471352
    #endif

    // TOLERANCES
    #ifndef QUETTA_TOLERANCE
    #define QUETTA_TOLERANCE 1e+30
    #endif
    #ifndef RONNA_TOLERANCE
    #define RONNA_TOLERANCE 1e+27
    #endif
    #ifndef YOTTA_TOLERANCE
    #define YOTTA_TOLERANCE 1e+24
    #endif
    #ifndef ZETTA_TOLERANCE
    #define ZETTA_TOLERANCE 1e+21
    #endif
    #ifndef EXA_TOLERANCE
    #define EXA_TOLERANCE 1e+18
    #endif
    #ifndef PETA_TOLERANCE
    #define PETA_TOLERANCE 1e+15
    #endif
    #ifndef TERA_TOLERANCE
    #define TERA_TOLERANCE 1e+12
    #endif
    #ifndef GIGA_TOLERANCE
    #define GIGA_TOLERANCE 1e+9
    #endif
    #ifndef MEGA_TOLERANCE
    #define MEGA_TOLERANCE 1e+6
    #endif
    #ifndef KILO_TOLERANCE
    #define KILO_TOLERANCE 1e+3
    #endif
    #ifndef HECTO_TOLERANCE
    #define HECTO_TOLERANCE 1e+2
    #endif
    #ifndef DEKA_TOLERANCE
    #define DEKA_TOLERANCE 1e+1
    #endif
    #ifndef DECI_TOLERANCE
    #define DECI_TOLERANCE 1e-1
    #endif
    #ifndef CENTI_TOLERANCE
    #define CENTI_TOLERANCE 1e-2
    #endif
    #ifndef MILLI_TOLERANCE
    #define MILLI_TOLERANCE 1e-3
    #endif
    #ifndef MICRO_TOLERANCE
    #define MICRO_TOLERANCE 1e-6
    #endif
    #ifndef NANO_TOLERANCE
    #define NANO_TOLERANCE 1e-9
    #endif
    #ifndef PICO_TOLERANCE
    #define PICO_TOLERANCE 1e-12
    #endif
    #ifndef FEMTO_TOLERANCE
    #define FEMTO_TOLERANCE 1e-15
    #endif
    #ifndef ATTO_TOLERANCE
    #define ATTO_TOLERANCE 1e-18
    #endif
    #ifndef ZEPTO_TOLERANCE
    #define ZEPTO_TOLERANCE 1e-21
    #endif
    #ifndef YOCTO_TOLERANCE
    #define YOCTO_TOLERANCE 1e-24
    #endif
    #ifndef RONTO_TOLERANCE
    #define RONTO_TOLERANCE 1e-27
    #endif
    #ifndef QUECTO_TOLERANCE
    #define QUECTO_TOLERANCE 1e-30
    #endif

    // colors
    const vec3 BLACK_COLOR   = vec3(0.0, 0.0, 0.0);
    const vec3 WHITE_COLOR   = vec3(1.0, 1.0, 1.0);
    const vec3 RED_COLOR     = vec3(1.0, 0.0, 0.0);
    const vec3 GREEN_COLOR   = vec3(0.0, 1.0, 0.0);
    const vec3 BLUE_COLOR    = vec3(0.0, 0.0, 1.0);
    const vec3 CYAN_COLOR    = vec3(0.0, 1.0, 1.0);
    const vec3 MAGENTA_COLOR = vec3(1.0, 0.0, 1.0);
    const vec3 YELLOW_COLOR  = vec3(1.0, 1.0, 0.0);

#endif // CONSTANTS

