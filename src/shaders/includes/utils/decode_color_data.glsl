#define MAX_VARIABLES 16

void decode_color_data(in vec4 color, in int color_bits, in int num_variables, out int[MAX_VARIABLES] variables)
{
    int variable_bits = (color_bits * 4) / num_variables;
    int variable_mask = (1 << variable_bits) - 1;
    int color_mask = (1 << color_bits) - 1;
    float color_scale = float(color_mask);

    // Reconstruct the bitstring from the color components
    int bitstring = 0;

    for (int i = 0; i < 4; i++)
    {
        bitstring <<= color_bits;
        bitstring |= int(color[i] * color_scale) & color_mask;
    }

    // Extract variables from the bitstring
    for (int i = num_variables - 1; i >= 0; i--)
    {
        variables[i] = bitstring & variable_mask;
        bitstring >>= variable_bits;
    }
}
