import * as THREE from 'three'

export function argmax(vec3) 
{
    let index = vec3.x < vec3.y ? 1 : 0;
    index += vec3.getComponent(index) < vec3.z ? (2 - index) : 0
    return index
}

export function dominantAxis(vec3) 
{
    const absVector = new THREE.Vector3(Math.abs(vec3.x), Math.abs(vec3.y), Math.abs(vec3.z))
    const index = argmax(absVector)
    const axis = new THREE.Vector3().setComponent(index, Math.sign(vec3.getComponent(index)))
    return axis
}

export function formatVector(vector, digits) 
{
    let sign = vector.toArray().map( (component) => ( component > 0 ) ? '+' : '-' )
    if ( vector instanceof THREE.Vector2 ) return `(${sign[0] + Math.abs(vector.x).toFixed(digits)}, ${sign[1] + Math.abs(vector.y).toFixed(digits)})`
    if ( vector instanceof THREE.Vector3 ) return `(${sign[0] + Math.abs(vector.x).toFixed(digits)}, ${sign[1] + Math.abs(vector.y).toFixed(digits)}, ${sign[2] + Math.abs(vector.z).toFixed(digits)})`
}
