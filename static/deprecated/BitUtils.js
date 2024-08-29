
// Create a 4-byte raw data buffer
const _buffer = new ArrayBuffer(4);

// Create a Float32Array view on the buffer
const _float32 = new Float32Array(_buffer);

// Create an Int32Array view on the buffer
const _int32 = new Int32Array(_buffer);
const _uint32 = new Uint32Array(_buffer);

// Function to convert float bits to int
export function floatBitsToInt(value) {
    // Store the float value in the Float32Array
    _float32[0] = value;
    // Return the int representation from the Int32Array
    return _int32[0];
}

// Function to convert float bits to int
export function intBitsToFloat(value) {
    // Store the float value in the Float32Array
    _int32[0] = value;
    // Return the int representation from the Int32Array
    return _float32[0];
}

// Function to convert float bits to int
export function floatBitsToUint(value) {
    // Store the float value in the Float32Array
    _float32[0] = value;
    // Return the int representation from the Int32Array
    return _uint32[0];
}

// Function to convert float bits to int
export function uintBitsToFloat(value) {
    // Store the float value in the Float32Array
    _uint32[0] = value;
    // Return the int representation from the Int32Array
    return _float32[0];
}

// Function to read a single bit from a number
export function readIntBits(number, position) {
    // Shift the number right by 'position' bits and mask the least significant bit
    return (number >> position) & 1;
}

// Function to read a byte (8 bits) from a number
export function readIntBytes(number, position) {
    // Shift the number right by 'position' bytes (8 bits per byte)
    // and then mask the least significant byte using & 0xFF
    return (number >> (position * 8)) & 0xFF;
}

// Function to read a nibble (4 bits) from a number
export function readIntNibbles(number, position) {
    // Shift the number right by 'position' nibbles (4 bits per nibble)
    // and then mask the least significant nibble using & 0xF
    return (number >> (position * 4)) & 0xF;
}

// Function to read a bitstring of specified length from a number
export function readIntBitstring(number, position, length) {
    // Create a bitmask with 'length' number of ones
    const bitmask = (1 << length) - 1;
    // Shift the number right by 'position' bits and mask the bitstring
    return (number >> position) & bitmask;
}
