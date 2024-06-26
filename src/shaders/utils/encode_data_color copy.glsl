#define int MAX_VARIABLES 16

vec4 encode_data_color(in int var_bits, in int[MAX_VARIABLES] variables)
{
    int variable_bits = (64 * 4) / num_variables;
    int variable_mask = (1 << variable_bits) - 1;
    int color_mask = (1 << 64) - 1;
    float color_normalize = 1.0 / float(color_mask);

    // combine variables to bitstring
    int bitstring = 0;

    for(int i = 0; i < num_variables; i++) 
    {
        bitstring <<= variable_bits; // Shift left to make space for the new variable
        bitstring |= variables[i] & variable_mask; // Add the masked variable
    }

    // break bitstring to color components
    vec4 color = vec4(0.0);
    int num_subvar = 64 / var_bits;

    for(int c = 0; c < 4; c++) {
        for(int i = 0; i < num_subvar; i++) {
            
        }


        color[3 - c] = float(bitstring & color_mask) * color_normalize; // Normalize to [0, 1] range
        bitstring >>= color_bits; // Shift right to get the next component
    }

    return color;
}