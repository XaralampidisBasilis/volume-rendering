//Returns the modified Bessel function I0(x) for any real x.
// source : http://www.ff.bg.ac.rs/Katedre/Nuklearna/SiteNuklearna/bookcpdf/c6-6.pdf, Chapter 6, Numerical Recipes in C

#ifndef BESSELI0
#define BESSELI0

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

float besseli0(float x)
{
    float y, ans;
    float ax = abs(x);

    // Polynomial fit for small values of x
    if (ax < 3.75)  {
        y = x / 3.75;
        y *= y;
        ans = 1.0 + y * (3.5156229 + y * (3.0899424 + y * (1.2067492 + y * (0.2659732 + y * (0.0360768 + y * 0.0045813)))));

    } else {
        y = 3.75 / x;
        ans = 0.00916281 + y * (-0.02057706 + y * (0.02635537 + y * (-0.01647633 + y * 0.00392377)));
        ans = 0.39894228 + y * (0.01328592 + y * (0.00225319 + y * (-0.00157565 + y * ans)));
        ans *= exp(ax) / sqrt(ax);       
    }
    
    return ans;
}

#endif
