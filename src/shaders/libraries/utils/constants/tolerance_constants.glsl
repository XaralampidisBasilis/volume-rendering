#ifndef TOLERANCE_CONSTANTS
#define TOLERANCE_CONSTANTS

struct ToleranceConstants {
    float QUETTA;
    float RONNA;
    float YOTTA;
    float ZETTA;
    float EXA;
    float PETA;
    float TERA;
    float GIGA;
    float MEGA;
    float KILO;
    float HECTO;
    float DEKA;
    float DECI;
    float CENTI;
    float MILLI;
    float MICRO;
    float NANO;
    float PICO;
    float FEMTO;
    float ATTO;
    float ZEPTO;
    float YOCTO;
    float RONTO;
    float QUECTO;
    float HIGHP_MAX;
    float HIGHP_MIN;
    float MEDIUMP_MAX;
    float MEDIUMP_MIN;
    float LOWP_MAX;
    float LOWP_MIN;
};

const ToleranceConstants TOLERANCE = ToleranceConstants(
    1e30,
    1e27,
    1e24,
    1e21,
    1e18,
    1e15,
    1e12,
    1e9,
    1e6,
    1e3,
    1e2,
    1e1,
    1e-1,
    1e-2,
    1e-3,
    1e-6,
    1e-9,
    1e-12,
    1e-15,
    1e-18,
    1e-21,
    1e-24,
    1e-27,
    1e-30,
    3.402823e38,
    1.175494e-38,
    16.384,
    0.000061035,
    256.0,
    0.00390625
);

#endif