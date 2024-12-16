import * as THREE from 'three'
import * as tf from '@tensorflow/tfjs'
import * as TensorUtils from './TensorUtils'
import { timeit } from './timeit'


/*
    Currently handles only spatial volume data without temporal information
*/
export default class VolumeProcessor 
{
    constructor(volume, renderer)
    {
        this.volume = volume
        this.setObjects()
        this.setVolumeParameters()

        // this.computeIntensityMap()
        // this.computeGradientMap()
        // this.computeTaylorMap()
        // this.computeOccupancyMap(0, 4)
        // this.computeOccupancyMipmaps(0, 4)
        // this.computeOccupancyDistanceMap(0, 2, 255)
        // this.computeOccupancyBoundingBox(0)
        // this.computeExtremaMap(4)
        // this.computeExtremaDistanceMap(4, 40)
        // this.downscaleIntensityMap(2)
        // this.smoothIntensityMap(1)
        // this.quantizeIntensityMap(256)
        // this.quantizeGradientMap(256)
        // this.quantizeTaylorMap(256)
    }

    setObjects()
    {
        this.intensityMap              = { params: null, tensor: null, texture: null}
        this.gradientMap               = { params: null, tensor: null, texture: null}
        this.taylorMap                 = { params: null, tensor: null, texture: null}
        this.occupancyMap              = { params: null, tensor: null, texture: null}
        this.occupancyDistanceMap      = { params: null, tensor: null, texture: null}
        this.occupancyMipmaps          = { params: null, tensor: null, texture: null}
        this.occupancyBoundingBox      = { params: null, tensor: null, texture: null}
        this.isosurfaceMap             = { params: null, tensor: null, texture: null}
        this.isosurfaceDistanceMap     = { params: null, tensor: null, texture: null}
        this.isosurfaceBoundingBox     = { params: null, tensor: null, texture: null}
        this.isosurfaceDualMap         = { params: null, tensor: null, texture: null}
        this.isosurfaceDistanceDualMap = { params: null, tensor: null, texture: null}
        this.minimaMap                 = { params: null, tensor: null, texture: null}
        this.maximaMap                 = { params: null, tensor: null, texture: null}
        this.extremaMap                = { params: null, tensor: null, texture: null}
        this.extremaDistanceMap        = { params: null, tensor: null, texture: null}
    }

    setVolumeParameters()
    {
        this.volume.params = 
        {
            dimensions       : new THREE.Vector3().fromArray(this.volume.dimensions),
            spacing          : new THREE.Vector3().fromArray(this.volume.spacing),
            size             : new THREE.Vector3().fromArray(this.volume.size),
            spacingLength    : new THREE.Vector3().fromArray(this.volume.spacing).length(),
            sizeLength       : new THREE.Vector3().fromArray(this.volume.size).length(),
            invDimensions    : new THREE.Vector3().fromArray(this.volume.dimensions.map(x => 1/x)),
            invSpacing       : new THREE.Vector3().fromArray(this.volume.spacing.map(x => 1/x)),
            invSize          : new THREE.Vector3().fromArray(this.volume.size.map(x => 1/x)),
            numVoxels        : this.volume.dimensions.reduce((voxels, dim) => voxels * dim, 1),
            shape            : this.volume.dimensions.toReversed().concat(1),
        }
    }

    // compute functions

    async computeIntensityMap()
    {
        timeit('computeIntensityMap', () =>
        {
            [this.intensityMap.tensor, this.intensityMap.params] = tf.tidy(() =>
            {
                const tensor  = tf.tensor4d(this.volume.data, this.volume.params.shape,'float32')
                const params = {...this.volume.params}

                return [tensor, params]
            })            
        })

        // console.log('intensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
    }

    async computeGradientMap()
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeGradientMap: intensityMap is not computed`)
        }

        timeit('computeGradientMap', () =>
        {
            [this.gradientMap.tensor, this.gradientMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.gradients3d(this.intensityMap.tensor, this.volume.params.spacing)
                const params =  {...this.volume.params}
                params.shape = tensor.shape

                return [tensor, params]
            })            
        })

        // console.log('gradientMap', this.gradientMap.params, this.gradientMap.tensor.dataSync())
    }
 
    async computeTaylorMap()
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeTaylorMap: intensityMap is not computed`)
        }
        if (!(this.gradientMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeTaylorMap: gradientMap is not computed`)
        }
        
        timeit('computeTaylorMap', () =>
        {
            [this.taylorMap.tensor, this.taylorMap.params] = tf.tidy(() =>
            {
                const tensor = tf.concat([this.intensityMap.tensor, this.gradientMap.tensor], 3)
                const params =  {...this.volume.params}
                params.shape = tensor.shape

                return [tensor, params]
            })
        })       

        // console.log('taylorMap', this.taylorMap.params, this.taylorMap.tensor.dataSync())s
    }

    async computeOccupancyMap(threshold = 0, subDivision = 4)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeOccupancyMipmaps: intensityMap is not computed`)
        }

        timeit('computeOccupancyMap', () =>
        {
            [this.occupancyMap.tensor, this.occupancyMap.params] = tf.tidy(() => 
            {
                const tensor = TensorUtils.occupancyMap(this.intensityMap.tensor, threshold, subDivision)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.shape = tensor.shape
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))

                return [tensor, params]
            })
        })

        // console.log('occupancyMap', this.occupancyMap.params, this.occupancyMap.tensor.dataSync())
    }

    async computeOccupancyMipmaps(threshold = 0, subDivision = 4)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeOccupancyMipmaps: intensityMap is not computed`)
        }

        timeit('computeOccupancyMipmaps', () =>
        {
            [this.occupancyMipmaps.tensor, this.occupancyMipmaps.params] = tf.tidy(() =>
            {
                const array = arrayUtils.occupancyMipmaps(this.intensityMap.tensor, threshold, subDivision)
                const tensor = TensorUtils.compactMipmaps(array)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.levels = occupancyMipmaps.length
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.shape = tensor.shape
                params.dimensions0 = new THREE.Vector3().fromArray(occupancyMipmaps[0].shape.slice(0, 3).toReversed())
                params.spacing0 = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(subDivision)
                params.size0 = new THREE.Vector3().copy(params.dimensions0).multiply(this.occupancyMipmaps.params.spacing0)

                return [tensor, params]
            })
        })    
        
        // console.log('occupancyMipmaps', this.occupancyMipmaps.params, this.occupancyMipmaps.tensor.dataSync())
    }

    async computeOccupancyDistanceMap(threshold = 0, subDivision = 2, maxIters = 255)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeOccupancyDistanceMap: intensityMap is not computed`)
        }
       
        timeit('computeOccupancyDistanceMap', () =>
        {
            [this.occupancyDistanceMap.tensor, this.occupancyDistanceMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.occupancyDistanceMap(this.intensityMap.tensor, threshold, subDivision, maxIters)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.shape = tensor.shape
                params.maxDistance = tensor.max().arraySync()
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(params.subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))
                
                return [tensor, params]
            })
        })

        // console.log('occupancyDistanceMap', this.occupancyDistanceMap.params, occupancyDistanceMap.dataSync())
    }

    async computeOccupancyBoundingBox(threshold = 0)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeOccupancyBoundingBox: intensityMap is not computed`)
        }

        timeit('computeOccupancyBoundingBox', () =>
        {
            this.occupancyBoundingBox.params = tf.tidy(() =>
            {
                const boundingBox = TensorUtils.occupancyBoundingBox(this.intensityMap.tensor, threshold)
                const params = {}
                params.threshold = threshold
                params.minCoords = new THREE.Vector3().fromArray(boundingBox.minCoords)
                params.maxCoords = new THREE.Vector3().fromArray(boundingBox.maxCoords)
                params.minPosition = new THREE.Vector3().fromArray(boundingBox.minCoords).multiply(this.volume.params.spacing)
                params.maxPosition = new THREE.Vector3().fromArray(boundingBox.maxCoords).multiply(this.volume.params.spacing)
                
                return params
            })          
        })

        // console.log('occupancyBoundingBox', this.occupancyBoundingBox.params)
    }

    async computeIsosurfaceMap(threshold = 0, subDivision = 4)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeIsosurfaceMipmaps: intensityMap is not computed`)
        }

        timeit('computeIsosurfaceMap', () =>
        {
            [this.isosurfaceMap.tensor, this.isosurfaceMap.params] = tf.tidy(() => 
            {
                const tensor = TensorUtils.isosurfaceMap(this.intensityMap.tensor, threshold, subDivision)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.shape = tensor.shape
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))

                return [tensor, params]
            })
        })

        // console.log('isosurfaceMap', this.isosurfaceMap.params, this.isosurfaceMap.tensor.dataSync())
    }

    async computeIsosurfaceDistanceMap(threshold = 0, subDivision = 2, maxIters = 255)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeIsosurfaceDistanceMap: intensityMap is not computed`)
        }
       
        timeit('computeIsosurfaceDistanceMap', () =>
        {
            [this.isosurfaceDistanceMap.tensor, this.isosurfaceDistanceMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.isosurfaceDistanceMap(this.intensityMap.tensor, threshold, subDivision, maxIters)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.shape = tensor.shape
                params.maxDistance = tensor.max().arraySync()
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(params.subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))
                
                return [tensor, params]
            })
        })

        console.log('isosurfaceDistanceMap', this.isosurfaceDistanceMap.params, this.isosurfaceDistanceMap.tensor.dataSync())
    }

    async computeIsosurfaceBoundingBox(threshold = 0)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeIsosurfaceBoundingBox: intensityMap is not computed`)
        }

        timeit('computeIsosurfaceBoundingBox', () =>
        {
            this.isosurfaceBoundingBox.params = tf.tidy(() =>
            {
                const boundingBox = TensorUtils.isosurfaceBoundingBox(this.intensityMap.tensor, threshold)
                const params = {}
                params.threshold = threshold
                params.minCoords = new THREE.Vector3().fromArray(boundingBox.minCoords)
                params.maxCoords = new THREE.Vector3().fromArray(boundingBox.maxCoords)
                params.minPosition = new THREE.Vector3().fromArray(boundingBox.minCoords).multiply(this.volume.params.spacing)
                params.maxPosition = new THREE.Vector3().fromArray(boundingBox.maxCoords).multiply(this.volume.params.spacing)
                
                return params
            })          
        })

        // console.log('isosurfaceBoundingBox', this.isosurfaceBoundingBox.params)
    }

    async computeIsosurfaceDualMap(threshold = 0, subDivision = 4)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeIsosurfaceMipDualMaps: intensityMap is not computed`)
        }

        timeit('computeIsosurfaceDualMap', () =>
        {
            [this.isosurfaceDualMap.tensor, this.isosurfaceDualMap.params] = tf.tidy(() => 
            {
                const tensor = TensorUtils.isosurfaceDualMap(this.intensityMap.tensor, threshold, subDivision)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.shape = tensor.shape
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))

                return [tensor, params]
            })
        })

        console.log('isosurfaceDualMap', this.isosurfaceDualMap.params, this.isosurfaceDualMap.tensor.dataSync())
    }

    async computeIsosurfaceDistanceDualMap(threshold = 0, subDivision = 2, maxIters = 255)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeIsosurfaceDistanceDualMap: intensityMap is not computed`)
        }
       
        timeit('computeIsosurfaceDistanceDualMap', () =>
        {
            [this.isosurfaceDistanceDualMap.tensor, this.isosurfaceDistanceDualMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.isosurfaceDistanceDualMap(this.intensityMap.tensor, threshold, subDivision, maxIters)
                const params = {}
                params.threshold = threshold
                params.subDivision = subDivision
                params.shape = tensor.shape
                params.maxDistance = tensor.max().arraySync()
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(params.subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.invSubDivision = 1/subDivision
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))
                
                return [tensor, params]
            })
        })

        console.log('isosurfaceDistanceDualMap', this.isosurfaceDistanceDualMap.params, this.isosurfaceDistanceDualMap.tensor.dataSync())
    }


    async computeExtremaMap(subDivision = 4)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeExtremaMap: intensityMap is not computed`)
        }

        timeit('computeExtremaMap', () =>
        {
            [this.extremaMap.tensor, this.extremaMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.extremaMap(this.intensityMap.tensor, subDivision)
                const params = {}
                params.subDivision = subDivision
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.shape = tensor.shape
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))
                
                return [tensor, params]
            })            
        })

        // console.log('extremaMap', this.extremaMap.params, this.extremaMap.tensor.dataSync())
    }

    async computeExtremaDistanceMap(subDivision = 4, maxDistance = 255)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`computeExtremaDistanceMap: intensityMap is not computed`)
        }
        
        timeit('computeExtremaDistanceMap', () =>
        {
            [this.extremaDistanceMap.tensor, this.extremaDistanceMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.extremaDistanceMap(this.intensityMap.tensor, subDivision, maxDistance)
                const params = {}
                params.subDivision = subDivision
                params.invSubDivision = 1/subDivision
                params.shape = tensor.shape
                params.maxDistance = tensor.max().arraySync()
                params.dimensions = new THREE.Vector3().fromArray(tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(params.subDivision)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.invDimensions = new THREE.Vector3().fromArray(params.dimensions.toArray().map(x => 1/x))
                params.invSpacing = new THREE.Vector3().fromArray(params.spacing.toArray().map(x => 1/x))
                params.invSize = new THREE.Vector3().fromArray(params.size.toArray().map(x => 1/x))
            
                return [tensor, params]
            })
        })

        // console.log('extremaDistanceMap', this.extremaDistanceMap.params, this.extremaDistanceMap.tensor.dataSync())
    }

    async normalizeIntensityMap()
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`normalizeIntensityMap: intensityMap is not computed`)
        }

        timeit('normalizeIntensityMap', () =>
        {
            [this.intensityMap.tensor, this.intensityMap.params] = tf.tidy(() =>
            {
                const [tensor, minValue, maxValue] = TensorUtils.normalize3d(this.intensityMap.tensor) 
                this.intensityMap.tensor.dispose()

                const params =  {...this.intensityMap.params}
                params.minValue = minValue[0]
                params.maxValue = maxValue[0]  

                return [tensor, params]
            })
        })

        // console.log('normalizedIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
    }

    async downscaleIntensityMap(scale = 2)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`downscaleIntensityMap: intensityMap is not computed`)
        }

        timeit('downscaleIntensityMap', () =>
        {
            [this.intensityMap.tensor, this.intensityMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.downscale3d(this.intensityMap.tensor, scale)
                this.intensityMap.tensor.dispose()

                const params =  {...this.intensityMap.params}
                params.downScale = scale
                params.dimensions = new THREE.Vector3().fromArray(this.intensityMap.tensor.shape.slice(0, 3).toReversed())
                params.spacing = new THREE.Vector3().copy(this.volume.params.spacing).multiplyScalar(scale)
                params.size = new THREE.Vector3().copy(params.dimensions).multiply(params.spacing)
                params.numBlocks = params.dimensions.toArray().reduce((numBlocks, dimension) => numBlocks * dimension, 1)
                params.shape = this.intensityMap.tensor.shape

                return [tensor, params]
            })
        })

        // console.log('downscaledIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
    }

    async smoothIntensityMap(radius = 1)
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`smoothIntensityMap: intensityMap is not computed`)
        }

        timeit('smoothIntensityMap', () =>
        {
            [this.intensityMap.tensor, this.intensityMap.params] = tf.tidy(() =>
            {
                const tensor = TensorUtils.smooth3d(this.intensityMap.tensor, radius)
                this.intensityMap.tensor.dispose()

                const params =  {...this.intensityMap.params}
                params.smoothingRadius = radius

                return [tensor, params]
            })
           
            
            // console.log('smoothedIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
        })
    }

    async quantizeIntensityMap()
    {
        if (!(this.intensityMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`quantizeIntensityMap: intensityMap is not computed`)
        }

        timeit('quantizeIntensityMap', () =>
        {
            [this.intensityMap.tensor, this.intensityMap.params] = tf.tidy(() =>
            {
                const [tensor, minValue, maxValue] = TensorUtils.quantize3d(this.intensityMap.tensor) 
                this.intensityMap.tensor.dispose()

                const params =  {...this.intensityMap.params}
                params.minValue = minValue
                params.maxValue = maxValue  

                return [tensor, params]
            })            
        })

        // console.log('quantizedIntensityMap', this.intensityMap.params, this.intensityMap.tensor.dataSync())
    }

    async quantizeGradientMap()
    {
        if (!(this.gradientMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`quantizeGradientMap: gradientMap is not computed`)
        }

        timeit('quantizeGradientMap', () =>
        {
            [this.gradientMap.tensor, this.gradientMap.params] = tf.tidy(() =>
            {
                const [tensor, minValue, maxValue] = TensorUtils.quantize3d(this.gradientMap.tensor) 
                this.gradientMap.tensor.dispose()

                const params =  {...this.gradientMap.params}
                params.minValue = new THREE.Vector3().fromArray(minValue)
                params.maxValue = new THREE.Vector3().fromArray(maxValue) 

                return [tensor, params]
            })
        })

        // console.log('quantizedGradientMap', this.gradientMap.params, this.gradientMap.tensor.dataSync())
    }

    async quantizeTaylorMap()
    {
        if (!(this.taylorMap.tensor instanceof tf.Tensor)) 
        {
            throw new Error(`quantizeTaylorMap: taylorMap is not computed`)
        }

        timeit('quantizeTaylorMap', () =>
        {
            [this.taylorMap.tensor, this.taylorMap.params] = tf.tidy(() =>
            {
                const [tensor, minValue, maxValue] = TensorUtils.quantize3d(this.taylorMap.tensor) 
                this.taylorMap.tensor.dispose()

                const params =  {...this.taylorMap.params}
                params.minValue = new THREE.Vector4().fromArray(minValue)
                params.maxValue = new THREE.Vector4().fromArray(maxValue) 

                return [tensor, params]
            })            
        })

        // console.log('quantizedTaylorMap', this.taylorMap.params, this.taylorMap.tensor.dataSync())
    }

    // helper functions

    getTexture(key, format, type) 
    {
        if (!(this[key].tensor instanceof tf.Tensor)) 
        {
            throw new Error(`${key} is not computed`)
        }

        if (this[key].texture instanceof THREE.Data3DTexture) 
        {
            this[key].texture.dispose()
        }

        timeit(`generateTexture(${key})`, () =>
        {
            let dimensions = this[key].params.dimensions.toArray()
            let array

            switch (type) 
            {
                case THREE.FloatType:
                    array = new Float32Array(this[key].tensor.dataSync())
                    break
                case THREE.UnsignedByteType:
                    array = new Uint8Array(this[key].tensor.dataSync())
                    break
                case THREE.UnsignedShortType:
                    array = new Uint16Array(this[key].tensor.dataSync())
                    break
                case THREE.ByteType:
                    array = new Int8Array(this[key].tensor.dataSync())
                    break
                case THREE.ShortType:
                    array = new Int16Array(this[key].tensor.dataSync())
                    break
                case THREE.IntType:
                    array = new Int32Array(this[key].tensor.dataSync())
                    break
                default:
                    throw new Error(`Unsupported type: ${type}`)
            }

            this[key].texture = new THREE.Data3DTexture(array, ...dimensions)
            this[key].texture.format = format
            this[key].texture.type = type
            this[key].texture.minFilter = THREE.LinearFilter
            this[key].texture.magFilter = THREE.LinearFilter
            this[key].texture.generateMipmaps = false
            this[key].texture.needsUpdate = true
        })

        return this[key].texture
    }
    
    destroy() 
    {
        Object.keys(this).forEach(key => 
        {
            // console.log(this[key])

            if (this[key]?.tensor instanceof tf.Tensor) 
            {
                this[key].tensor.dispose()
                this[key].tensor = null
            }

            if (this[key]?.texture instanceof THREE.Data3DTexture) 
            {
                this[key].texture.dispose()
                this[key].texture = null
            }
        
            if (this[key]?.params) 
            {
                delete this[key].params
            }

            if (this[key])
            {
                this[key] = null
            }
        })

        this.volume = null;
    
        console.log("VolumeProcessor destroyed.");
    }
    
}