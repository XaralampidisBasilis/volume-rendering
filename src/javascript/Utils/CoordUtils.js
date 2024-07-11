import * as THREE from 'three'

// vector3 input overloaded function
   
export function sub2ind(dim, sub)
{
    return sub.x + sub.y * dim.x + sub.z * dim.x * dim.z
}

export function ind2sub(dim, ind, sub) 
{
    const XY = dim.x * dim.y;
    const xy = ind % XY;

    sub.z = Math.floor(ind / XY);
    sub.y = Math.floor(xy / dim.x);
    sub.x = xy % dim.x;

    return sub;
}

export function box2ind(dim, boxmin, boxmax) 
{
    const boxdim = boxmax.clone().sub(boxmin).addScalar(1)
    const indices = new Array(boxdim.x * boxdim.y * boxdim.z);

    const strideZ = dim.x * dim.y
    const strideY = dim.x
    let index = 0;

    for (let z = boxmin.z; z < boxmax.z; z++) {
        const offsetZ = strideZ * z;

        for (let y = boxmin.y; y < boxmax.y; y++) {
            const offsetY = strideY * y;

            for (let x = boxmin.x; x < boxmax.x; x++) {
                indices[index++] = x + offsetY + offsetZ;
            }
        }
    }

    return indices;
}

// arrays input overloaded functions

/*
 * Converts a 3-dimensional subscript array to a linear index
 *
 * @param in dim: 3-array of dimensions ex [2 2 2]
 * @param in subn: 3-array of indices ex [0, 1, 1]
 * @param out: a linear index ex 6
 */
export function sub2ind(dim, sub)
{
    return sub[0] + sub[1] * dim[0] + sub[2] * dim[0] * dim[1]
}

/*
 * Converts a linear index to 3-dimensional subscript array
 *
 * @param in dim: 3-array of dimensions ex [2 2 2]
 * @param in ind: linear index number ex 6
 * @param out: 3-array of indices ex [0, 1, 1]
 */
export function ind2sub(dim, ind) 
{
    const sub = new Array(3)
    const XY = dim[0] * dim[1];
    const xy = ind % XY;

    sub[0] = Math.floor(ind / XY);
    sub[1] = Math.floor(xy / dim[0]);
    sub[2] = xy % dim[0];

    return sub;
}

/*
 * Converts 3-dimensional box subscripts to linear indices
 *
 * @param in dim: array of dimensions ex [3 3 3]
 * @param in boxmin: array of box min indices ex [1 1 1]
 * @param in boxmax: array of box max indices ex [2 2 2]
 * @param out: linear box indices ex [4 5 7 8]
 */
export function box2ind(dim, boxmin, boxmax) 
{
    const boxdim = boxmax.map((max, i) => max - boxmin[i] + 1)
    const indices = new Array(boxdim[0] * boxdim[1] * boxdim[2])
    
    const strideZ = dim[0] * dim[1]
    const strideY = dim[0]
    let index = 0;

    for (let z = boxmin[2]; z <= boxmax[2]; z++) {
        const offsetZ = strideZ * z;

        for (let y = boxmin[1]; y <= boxmax[1]; y++) {
            const offsetY = strideY * y;

            for (let x = boxmin[0]; x <= boxmax[0]; x++) {
                indices[index++] = x + offsetY + offsetZ;
            }
        }
    }

    return indices;
}

/*
 * Converts n-dimensional box subscripts to linear indices
 *
 * @param in dim: array of dimensions ex [3 3]
 * @param in boxmin: array of box min indices ex [1 1]
 * @param in boxmax: array of box max indices ex [2 2]
 * @param out: linear box indices ex [4 5 7 8]
 */
export function boxn2ind(dim, boxmin, boxmax)
{
    const boxdim = boxmax.map((max, i) => max - boxmin[i] + 1)
    const count = boxdim.reduce((product, currentValue) => product * currentValue, 1)
    const indices = new Array(count);

    for (let n = 0; n < count; n++)
    {
        const subm = ind2subm(boxdim, n).map((boxi, i) => boxi + boxmin[i])
        indices[n] = subn2ind(dim, subm)
    }

    return indices
}

/*
 * Converts a n-dimensional subscript to a linear index
 *
 * @param in dim: array of dimensions ex [2 2 2]
 * @param in subn: array of n-dimensional indices ex [0, 1]
 * @param out: a linear index ex 2
 */
export function subn2ind(dim, subn)
{
    const strides = [1, ...cumprod(dim).slice(0, -1)]
    let ind = 0

    for (let i = 0; i < subn.length; i++ )
        ind += subn[i] * strides[i]

    return ind
} 

/*
 * Converts a linear index to an m-dimensional subscript
 *
 * @param in dim: array of dimensions ex [2 2 2]
 * @param in ind: a number of linear index ex 4
 * @param in m: a number of output dimensions ex 2
 * @param out: array of m dimensions indices ex [0 2]
 */
export function ind2subm(dim, ind, m = dim.length)
{
    const subm = new Array(m)
    let residue = ind

    for (let i = 0; i < m - 1; i++)
    {
        subm[i] = residue % dim[i]
        residue = Math.floor(residue / dim[i])
    }
    subm[m - 1] = residue

    return subm
} 

/*
 * Converts n-dimensional indices to m-dimensional
 *
 * @param in dim: array of dimensions ex [2 2 2]
 * @param in subn: array of n dimensional indices ex [0, 1, 1] 
 * @param in m: a number of output dimensions ex 2
 * @param out: array of m dimensions indices ex [0 3]
 */
export function subn2subm(dim, subn, m = dim.length)
{
    const ind = subn2ind(dim, subn)
    const subm = ind2subm(dim, ind, m)

    return subm
} 

/*
 * Calculates the cumulative products of the array.
 *
 * @param in array: an array of numbers ex [1 2 3]
 * @param out: an array of cumulative products ex [1 1*2 1*2*3]
 */
export function cumprod(array) 
{
    let result = new Array(array.length)
    let product = 1

    for (let i = 0; i < array.length; i++) 
    {
        product *= array[i]
        result[i] = product
    }

    return result
}