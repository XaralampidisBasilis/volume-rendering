#ifndef BESSELI
#define BESSELI

//Returns the modified Bessel function I0(x) for any real x.
// source : http://www.ff.bg.ac.rs/Katedre/Nuklearna/SiteNuklearna/bookcpdf/c6-6.pdf, Chapter 6, Numerical Recipes in C

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

//Returns the modified Bessel function I1(x) for any real x.
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

//Returns the modified Bessel function In(x) for any real x and n ≥ 2.

#define ACC 40.0  // Accuracy factor
#define BIGNO 1.0e+10
#define BIGNI 1.0e-10

float besseli(int n, float x)
{
    float bi, bim, bip, tox, ans;
    float ax = abs(x);
    if (ax < MICRO_TOLERANCE) return 0.0;

    float bessi0 = besseli0(x);
    if (n == 0) return bessi0;

    float bessi1 = besseli1(x);
    if (n == 1) return bessi1;

    // tox is 2 / |x| 
    tox = 2.0 / ax;
    bip = 0.0;
    bi = 1.0;
    ans = 0.0;

    // Calculate the number of steps based on ACC and n
    int jmax = int(2.0 * (float(n) + sqrt(ACC * float(n))));

    // Downward recurrence from even m
    for (int j = jmax; j > 0; j--) {
        bim = bip + float(j) * tox * bi;
        bip = bi;
        bi  = bim;

        // Renormalize to prevent overflow if bi is too large
        if (abs(bi) > BIGNO) { 
            ans *= BIGNI;
            bip *= BIGNI;
            bi  *= BIGNI;
        }
        if (j == n) ans = bip;
    }

    // Normalize with besseli0
    ans *= bessi0 / bi;

    // Handle negative x and odd n with no branching
    float is_negative_x = step(0.0, -x);  // 1 if x < 0, 0 otherwise
    float is_odd_n = float(n % 2);        // 1 if n is odd, 0 if even

    return mix(ans, -ans, is_negative_x * is_odd_n);
}

#endif // BESSELI
