import * as THREE from 'three'

export default class OccumapHelper extends THREE.LineSegments
{
    constructor(occumap)
    {
        const material = OccumapHelper.computeMaterial()
        const geometry = OccumapHelper.computeGeometry(occumap)
        
        super(geometry, material)

        this.occumap = occumap
    }

    static computeMaterial()
    {
        const material = new THREE.LineBasicMaterial()
        material.toneMapped = false
        material.color = 0xffff00

        return material
    }

    static computeGeometry(occumap)
    {
        const geometry = new THREE.BufferGeometry()

        const combinedPoints = []
        const combinedIndices = []

        let count = 0

        for (let n = 0; n < occumap.data.length; n++) 
        {
            if (occumap.data[n]) 
            {
                const box = occumap.getBlockBox(n)

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
        
        geometry.setFromPoints(combinedPoints)
        geometry.setIndex(new THREE.Uint32BufferAttribute(combinedIndices, 1))

        return geometry
    }

    updateOccumap(occumap)
    {
        this.occumap = occumap
        this.geometry.dispose()
        this.geometry = OccumapHelper.computeGeometry(occumap)
    }

	dispose() 
    {
		this.geometry.dispose()
		this.material.dispose()
	}
    
    
}