//Returns the modified Bessel function In(x) for any real x and n ≥ 2.
// source : http://www.ff.bg.ac.rs/Katedre/Nuklearna/SiteNuklearna/bookcpdf/c6-6.pdf, Chapter 6, Numerical Recipes in C

#ifndef BESSELI
#define BESSELI

#ifndef MICRO_TOLERANCE
#define MICRO_TOLERANCE 1e-6
#endif
#ifndef BESSELI0
#include "./besseli0"
#endif
#ifndef BESSELI1
#include "./besseli1"
#endif


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
