import * as THREE from 'three'

// vector3 and box3 input functions

/*
 * Converts a 3-vector to a linear index
 *
 * @param in dim: 3-vector of dimensions ex THREE.Vector(2, 2, 2)
 * @param in sub: 3-vector of indices ex THREE.Vector(1, 1, 1)
 * @param out: a linear index ex 6
 */
export function vec2ind(dim, vec)
{
    return vec.x + vec.y * dim.x + vec.z * dim.x * dim.z
}

/*
 * Converts a a linear index to a 3-vector
 *
 * @param in dim: 3-vector of dimensions ex THREE.Vector(2, 2, 2)
 * @param in ind: a linear index ex 6
 * @param out sub: 3-vector of indices ex THREE.Vector(1, 1, 1)
 */
export function ind2vec(dim, ind, vec) 
{
    const XY = dim.x * dim.y;
    const xy = ind % XY;

    vec.z = Math.floor(ind / XY);
    vec.y = Math.floor(xy / dim.x);
    vec.x = xy % dim.x;

    return vec;
}

/*
 * Converts 3-axis alligned bounding box to linear indices
 *
 * @param in dim: 3-vector of dimensions ex THREE.Vector(3, 3, 3)
 * @param in aabb: 3-alligned bounding box ex THREE.Box3(THREE.Vector(1, 1, 1), THREE.Vector(2, 2, 2))
 * @param out: linear box indices ex [4 5 7 8]
 */
export function box2ind(dim, box) 
{
    const boxdim = box.getSize(new THREE.Vector3())
    const indices = new Array(boxdim.x * boxdim.y * boxdim.z);

    const strideZ = dim.x * dim.y
    const strideY = dim.x
    let index = 0;

    for (let z = box.min.z; z <= box.max.z; z++) {
        const offsetZ = strideZ * z;

        for (let y = box.min.y; y <= box.max.y; y++) {
            const offsetY = strideY * y;

            for (let x = box.min.x; x <= box.max.x; x++) {
                indices[index++] = x + offsetY + offsetZ;
            }
        }
    }

    return indices;
}

/*
 * Converts 3-bounds to linear indices
 *
 * @param in dim: 3-vector of dimensions ex THREE.Vector(3, 3, 3)
 * @param in boundsmax: 3-vector of min bounds ex THREE.Vector(1, 1, 1)
 * @param in boundsmax: 3-vector of max bounds ex THREE.Vector(2, 2, 2)
 * @param out: linear indices ex [4 5 7 8]
 */
export function bounds2ind(dim, boundsmin, boundsmax) 
{
    const boundsdim = boundsmax.clone().sub(boundsmin).addScalar(1)
    const indices = new Array(boundsdim.x * boundsdim.y * boundsdim.z);

    const strideZ = dim.x * dim.y
    const strideY = dim.x
    let index = 0;

    for (let z = boundsmin.z; z <= boundsmax.z; z++) {
        const offsetZ = strideZ * z;

        for (let y = boundsmin.y; y <= boundsmax.y; y++) {
            const offsetY = strideY * y;

            for (let x = boundsmin.x; x <= boundsmax.x; x++) {
                indices[index++] = x + offsetY + offsetZ;
            }
        }
    }

    return indices;
}

/*
 * Converts max 3-range to linear indices
 *
 * @param in dim: 3-vector of dimensions ex THREE.Vector(3, 3, 3)
 * @param in range: 3-vector of max range ex THREE.Vector(1, 1, 1)
 * @param out: linear indices ex [4 5 7 8]
 */
export function range2ind(dim, range) 
{
    const indices = new Array(range.x * range.y * range.z);

    const strideZ = dim.x * dim.y
    const strideY = dim.x
    let index = 0;

    for (let z = 0; z <= range.z; z++) {
        const offsetZ = strideZ * z;

        for (let y = 0; y <= range.y; y++) {
            const offsetY = strideY * y;

            for (let x = 0; x <= range.x; x++) {
                indices[index++] = x + offsetY + offsetZ;
            }
        }
    }

    return indices;
}

// arrays input functions

/*
 * Converts a 3-dimensional subscript array to a linear index
 *
 * @param in dim: 3-array of dimensions ex [2 2 2]
 * @param in sub: 3-array of indices ex [0, 1, 1]
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

    sub[2] = Math.floor(ind / XY);
    sub[1] = Math.floor(xy / dim[0]);
    sub[0] = xy % dim[0];

    return sub;
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