
#if SKIPPING_METHOD == 0
#include "./update_block/update_block_occupancy"

#elif SKIPPING_METHOD == 1
#include "./update_block/update_block_isotropic"
    
#elif SKIPPING_METHOD == 2
#include "./update_block/update_block_anisotropic"

#elif SKIPPING_METHOD == 3
#include "./update_block/update_block_extended_isotropic"
   
#elif SKIPPING_METHOD == 4
#include "./update_block/update_block_extended_anisotropic"
#endif    
