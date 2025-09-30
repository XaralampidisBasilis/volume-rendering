#ifndef COLORMAP
#define COLORMAP

#include "./colormap/parula"
#include "./colormap/turbo"
#include "./colormap/hsv"
#include "./colormap/hot"
#include "./colormap/cool"
#include "./colormap/spring"
#include "./colormap/summer"
#include "./colormap/autumn"
#include "./colormap/winter"
#include "./colormap/gray"
#include "./colormap/bone"
#include "./colormap/copper"
#include "./colormap/pink"
#include "./colormap/jet"
#include "./colormap/pasteljet"
#include "./colormap/viridis"
#include "./colormap/plasma"
#include "./colormap/inferno"
#include "./colormap/magma"
#include "./colormap/cividis"

vec3 colormap(in float t, in int type)
{
    if      (type == COLORMAP_PARULA) return parula(t);
    else if (type == COLORMAP_TURBO) return turbo(t);
    else if (type == COLORMAP_HSV) return hsv(t);
    else if (type == COLORMAP_HOT) return hot(t);
    else if (type == COLORMAP_COOL) return cool(t);
    else if (type == COLORMAP_SPRING) return spring(t);
    else if (type == COLORMAP_SUMMER) return summer(t);
    else if (type == COLORMAP_AUTUMN) return autumn(t);
    else if (type == COLORMAP_WINTER) return winter(t);
    else if (type == COLORMAP_GRAY) return gray(t);
    else if (type == COLORMAP_BONE) return bone(t);
    else if (type == COLORMAP_COPPER) return copper(t);
    else if (type == COLORMAP_PINK) return pink(t);
    else if (type == COLORMAP_JET) return jet(t);
    else if (type == COLORMAP_PASTELJET) return pasteljet(t);
    else if (type == COLORMAP_VIRIDIS) return viridis(t);
    else if (type == COLORMAP_PLASMA) return plasma(t);
    else if (type == COLORMAP_INFERNO) return inferno(t);
    else if (type == COLORMAP_MAGMA) return magma(t);
    else if (type == COLORMAP_CIVIDIS) return cividis(t);

    else return vec3(0.0); 
}

#endif