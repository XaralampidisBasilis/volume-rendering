import * as THREE from 'three'
import { Uint32BufferAttribute } from 'three/src/core/BufferAttribute.js'

export default class OccumapHelper
{
    constructor(occumap)
    {
        this.occumap = occumap
        
        this.setMaterial()
        this.setGeometry()
        
        this.instance = new THREE.LineSegments(this.geometry, this.material)
    }

    setMaterial()
    {
        this.material = new THREE.LineBasicMaterial()
        this.material.toneMapped = false
        this.material.depthWrite = true
        this.material.transparent = true
        this.material.color = 0xffff00
    }

    setGeometry()
    {
        this.geometry = new THREE.BufferGeometry()

        const combinedPoints = []
        const combinedIndices = []

        let count = 0

        for (let n = 0; n < this.occumap.data.length; n++) 
        {
            if (this.occumap.data[n]) 
            {
                const box = this.occumap.getBlockBox(n)

                const points = [
                    new THREE.Vector3(box.max.x, box.max.y, box.max.z),
                    new THREE.Vector3(box.min.x, box.max.y, box.max.z),
                    new THREE.Vector3(box.min.x, box.min.y, box.max.z),
                    new THREE.Vector3(box.max.x, box.min.y, box.max.z),
                    new THREE.Vector3(box.max.x, box.max.y, box.min.z),
                    new THREE.Vector3(box.min.x, box.max.y, box.min.z),
                    new THREE.Vector3(box.min.x, box.min.y, box.min.z),
                    new THREE.Vector3(box.max.x, box.min.y, box.min.z),
                ]

                const indices = [ 0, 1, 1, 2, 2, 3, 3, 0, 4, 5, 5, 6, 6, 7, 7, 4, 0, 4, 1, 5, 2, 6, 3, 7 ]
                    .map((index) => index + count * 8)
                                             
                combinedPoints.push(...points)
                combinedIndices.push(...indices)
                count++

            }
        }
        
        this.geometry.setFromPoints(combinedPoints)
        this.geometry.setIndex(new THREE.Uint32BufferAttribute(combinedIndices, 1))
    }

    updateOccumap(occumap)
    {
        this.occumap = occumap
        this.geometry.dispose()
        this.setGeometry()
        this.instance.geometry = this.geometry
    }

	dispose() 
    {
		this.geometry.dispose()
		this.material.dispose()
	}
    
    
}