import * as THREE from 'three';

// Function to reshape 3d coordinates to 1d index
export function reshape3DTo1D(dimensions, position3) {
    // pos3 in [0, size]
    return position3.z * dimensions.x * dimensions.y + position3.y * dimensions.x + position3.x;
}

// Function to reshape 1d index to 3d coordinates
export function reshape1DTo3D(dimensions, position1, position3) {
    // pos1 in [0, size]
    const sizeXY = dimensions.x * dimensions.y;
    position3.z = Math.floor(position1 / sizeXY);

    const posXY = position1 % sizeXY;
    position3.y = Math.floor(posXY / dimensions.x);
    position3.x = posXY % dimensions.x;

    return position3;
}

// Function to reshape 3d coordinates to 2d coordinates
export function reshape3DTo2D(dimensions, position3, position2) {
    // pos3 in [0, size]
    position2.x = position3.x;
    position2.y = Math.floor(position3.z) * dimensions.y + position3.y;

    return position2;
}

// Function to reshape 2d coordinates to 3d coordinates
export function reshape2DTo3D(dimensions, position2, position3) {
    // pos2 in [0, size]
    position3.x = position2.x;
    position3.y = position2.y % dimensions.y;
    position3.z = Math.floor(position2.y / dimensions.y);

    return position3;
}

export function computeIndices(size, min, max) {
    const indices = [];

    for (let z = min.z; z < max.z; z++) {
        const offsetZ = size.x * size.y * z;

        for (let y = min.y; y < max.y; y++) {
            const offsetY = size.x * y;

            for (let x = min.x; x < max.x; x++) {
                indices.push(x + offsetY + offsetZ);
            }
        }
    }

    return indices;
}
   