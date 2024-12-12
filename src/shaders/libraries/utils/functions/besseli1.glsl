//Returns the modified Bessel function I1(x) for any real x.
// source : http://www.ff.bg.ac.rs/Katedre/Nuklearna/SiteNuklearna/bookcpdf/c6-6.pdf, Chapter 6, Numerical Recipes in C

#ifndef BESSELI1
#define BESSELI1

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif

float besseli1(float x)
{
    float y, ans;
    float ax = abs(x);

    // Polynomial fit for small values of x
    if (ax < 3.75)  {
        y = x / 3.75;
        y *= y;
        ans = ax * (0.5 + y * (0.87890594 + y * (0.51498869 + y * (0.15084934 + y * (0.02658733 + y * (0.00301532 + y * 0.00032411))))));

    } else {
        y = 3.75 / x;
        ans = 0.02282967 + y * (-0.02895312 + y * (0.01787654 - y * 0.00420059));
        ans = 0.39894228 + y * (-0.03988024 + y * (-0.00362018 + y * (0.00163801 + y * (-0.01031555 + y * ans))));
        ans *= exp(ax) / sqrt(ax);
    }

    return ans * sign(x);
}

#endif

