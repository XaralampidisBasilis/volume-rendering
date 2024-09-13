
// spacing_isotropic
#if SPACING_METHOD == 1  
#include "./modules/spacing_isotropic"
   
// spacing_directional
#elif SPACING_METHOD == 2
#include "./modules/spacing_directional"

// spacing_traversal
#elif SPACING_METHOD == 3
#include "./modules/spacing_traversal"

#else  
#error "unknown: SPACING_METHOD"

#endif // SPACING_METHOD